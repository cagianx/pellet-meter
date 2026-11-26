/*
 * Visualizzatore STL del sito pellet-meter.
 *
 * Perche' scritto a mano invece di importare una libreria: le alternative
 * pronte (three.js e simili) pesano centinaia di kilobyte e andrebbero
 * comunque copiate dentro il sito, perche' la regola e' che il sito non
 * dipende da una CDN. Qui serve una cosa sola — far ruotare un solido di
 * poche migliaia di triangoli — e costa 13 kB di sorgente commentato, 5 kB
 * compressi: un quarto dell'STL che carica.
 *
 * Non sostituisce le immagini statiche. Se manca JavaScript, manca WebGL o
 * l'STL non arriva, il contenitore mostra gia' da fermo un testo e il link
 * per scaricare il modello: la pagina resta utile.
 *
 * Il file viene caricato solo dalle pagine che lo citano, e si inizializza
 * da solo anche quando docmd naviga in modalita' SPA, dove gli script del
 * contenuto vengono rieseguiti a ogni cambio pagina: per questo ogni
 * contenitore viene marcato, e inizializzarlo due volte non succede.
 */

(function () {
  'use strict';

  var COLORE = [0.23, 0.56, 0.60];   // lo stesso teal dei render
  var SFONDO = [0.97, 0.97, 0.97, 1.0];
  var ALTEZZA = 420;                 // px

  // --- STL binario -----------------------------------------------------
  //
  // tools/render.sh esporta in binstl: 80 byte di intestazione, il numero
  // di triangoli, poi 50 byte per triangolo (normale, tre vertici, 2 byte
  // di attributi). Se i conti non tornano il file non e' quello che
  // crediamo, e tirare dritto disegnerebbe spazzatura.
  function leggiStl(buffer) {
    var d = new DataView(buffer);
    if (buffer.byteLength < 84) throw new Error('file troppo corto');
    var n = d.getUint32(80, true);
    if (84 + n * 50 !== buffer.byteLength) {
      throw new Error('non e\' un STL binario');
    }
    var pos = new Float32Array(n * 9);
    var nor = new Float32Array(n * 9);
    for (var i = 0; i < n; i++) {
      var b = 84 + i * 50;
      var nx = d.getFloat32(b, true);
      var ny = d.getFloat32(b + 4, true);
      var nz = d.getFloat32(b + 8, true);
      var v = [];
      for (var k = 0; k < 3; k++) {
        v.push([d.getFloat32(b + 12 + k * 12, true),
                d.getFloat32(b + 16 + k * 12, true),
                d.getFloat32(b + 20 + k * 12, true)]);
      }
      // Normale a zero: la si ricava dal triangolo. OpenSCAD la scrive,
      // altri esportatori no, e senza normale il pezzo esce nero.
      if (nx === 0 && ny === 0 && nz === 0) {
        var ax = v[1][0] - v[0][0], ay = v[1][1] - v[0][1], az = v[1][2] - v[0][2];
        var bx = v[2][0] - v[0][0], by = v[2][1] - v[0][1], bz = v[2][2] - v[0][2];
        nx = ay * bz - az * by;
        ny = az * bx - ax * bz;
        nz = ax * by - ay * bx;
      }
      for (var j = 0; j < 3; j++) {
        var o = i * 9 + j * 3;
        pos[o] = v[j][0]; pos[o + 1] = v[j][1]; pos[o + 2] = v[j][2];
        nor[o] = nx; nor[o + 1] = ny; nor[o + 2] = nz;
      }
    }
    return { pos: pos, nor: nor, triangoli: n };
  }

  function ingombro(pos) {
    var min = [Infinity, Infinity, Infinity], max = [-Infinity, -Infinity, -Infinity];
    for (var i = 0; i < pos.length; i += 3) {
      for (var a = 0; a < 3; a++) {
        if (pos[i + a] < min[a]) min[a] = pos[i + a];
        if (pos[i + a] > max[a]) max[a] = pos[i + a];
      }
    }
    var centro = [0, 0, 0], raggio = 0;
    for (var b = 0; b < 3; b++) {
      centro[b] = (min[b] + max[b]) / 2;
      raggio += Math.pow((max[b] - min[b]) / 2, 2);
    }
    return { centro: centro, raggio: Math.sqrt(raggio) || 1 };
  }

  // --- Matrici 4x4, colonna per colonna (come le vuole WebGL) ----------

  function prodotto(a, b) {
    var r = new Float32Array(16);
    for (var c = 0; c < 4; c++) {
      for (var f = 0; f < 4; f++) {
        r[c * 4 + f] = a[f] * b[c * 4] + a[4 + f] * b[c * 4 + 1] +
                       a[8 + f] * b[c * 4 + 2] + a[12 + f] * b[c * 4 + 3];
      }
    }
    return r;
  }

  function trasla(x, y, z) {
    return new Float32Array([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, x, y, z, 1]);
  }

  function ruotaX(g) {
    var c = Math.cos(g), s = Math.sin(g);
    return new Float32Array([1, 0, 0, 0, 0, c, s, 0, 0, -s, c, 0, 0, 0, 0, 1]);
  }

  function ruotaZ(g) {
    var c = Math.cos(g), s = Math.sin(g);
    return new Float32Array([c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
  }

  function prospettiva(fov, aspetto, vicino, lontano) {
    var f = 1 / Math.tan(fov / 2);
    return new Float32Array([
      f / aspetto, 0, 0, 0,
      0, f, 0, 0,
      0, 0, (lontano + vicino) / (vicino - lontano), -1,
      0, 0, (2 * lontano * vicino) / (vicino - lontano), 0
    ]);
  }

  // --- Shader ----------------------------------------------------------
  //
  // Luce diffusa da due direzioni piu' una quota di ambiente: una sola
  // luce lascia completamente piatte le facce che le danno le spalle, ed
  // e' proprio il difetto dei render statici dal basso.

  var VERTICE = [
    'attribute vec3 posizione;',
    'attribute vec3 normale;',
    'uniform mat4 mv;',
    'uniform mat4 proiezione;',
    'varying vec3 n;',
    'void main() {',
    '  n = mat3(mv) * normale;',
    '  gl_Position = proiezione * mv * vec4(posizione, 1.0);',
    '}'
  ].join('\n');

  var FRAMMENTO = [
    'precision mediump float;',
    'uniform vec3 colore;',
    'varying vec3 n;',
    'void main() {',
    '  vec3 u = normalize(n);',
    '  float a = max(dot(u, normalize(vec3(0.3, 0.5, 1.0))), 0.0);',
    '  float b = max(dot(u, normalize(vec3(-0.6, -0.4, 0.5))), 0.0);',
    '  float luce = 0.28 + 0.62 * a + 0.22 * b;',
    '  gl_FragColor = vec4(colore * luce, 1.0);',
    '}'
  ].join('\n');

  function compila(gl, tipo, sorgente) {
    var s = gl.createShader(tipo);
    gl.shaderSource(s, sorgente);
    gl.compileShader(s);
    if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) {
      throw new Error(gl.getShaderInfoLog(s));
    }
    return s;
  }

  // --- Scena -----------------------------------------------------------

  function avvia(contenitore, modello, link) {
    var tela = document.createElement('canvas');
    tela.style.width = '100%';
    tela.style.height = ALTEZZA + 'px';
    tela.style.display = 'block';
    tela.style.cursor = 'grab';
    tela.style.touchAction = 'none';
    tela.setAttribute('role', 'img');
    tela.setAttribute('aria-label',
      'Modello tridimensionale del contenitore, ruotabile');

    var gl = tela.getContext('webgl') || tela.getContext('experimental-webgl');
    if (!gl) throw new Error('WebGL non disponibile');

    var programma = gl.createProgram();
    gl.attachShader(programma, compila(gl, gl.VERTEX_SHADER, VERTICE));
    gl.attachShader(programma, compila(gl, gl.FRAGMENT_SHADER, FRAMMENTO));
    gl.linkProgram(programma);
    if (!gl.getProgramParameter(programma, gl.LINK_STATUS)) {
      throw new Error(gl.getProgramInfoLog(programma));
    }
    gl.useProgram(programma);

    function buffer(dati, nome) {
      var b = gl.createBuffer();
      gl.bindBuffer(gl.ARRAY_BUFFER, b);
      gl.bufferData(gl.ARRAY_BUFFER, dati, gl.STATIC_DRAW);
      var loc = gl.getAttribLocation(programma, nome);
      gl.enableVertexAttribArray(loc);
      gl.vertexAttribPointer(loc, 3, gl.FLOAT, false, 0, 0);
    }
    buffer(modello.pos, 'posizione');
    buffer(modello.nor, 'normale');

    var uMv = gl.getUniformLocation(programma, 'mv');
    var uProiezione = gl.getUniformLocation(programma, 'proiezione');
    gl.uniform3fv(gl.getUniformLocation(programma, 'colore'), COLORE);
    gl.enable(gl.DEPTH_TEST);
    gl.enable(gl.CULL_FACE);
    gl.clearColor(SFONDO[0], SFONDO[1], SFONDO[2], SFONDO[3]);

    var misure = ingombro(modello.pos);
    // L'inquadratura di partenza e' la stessa dei render statici: tre
    // quarti dall'alto. Chi arriva dalla pagina ritrova la stessa scatola
    // nella stessa posa, e la confronta invece di doverla ricercare.
    var azimut = -30 * Math.PI / 180;
    var alzata = 30 * Math.PI / 180;
    var distanza = misure.raggio / Math.sin(0.5) * 1.15;
    var distanzaIniziale = distanza;

    function disegna() {
      var dpr = Math.min(window.devicePixelRatio || 1, 2);
      var larghezza = tela.clientWidth || 600;
      var altezza = tela.clientHeight || ALTEZZA;
      if (tela.width !== Math.round(larghezza * dpr)) {
        tela.width = Math.round(larghezza * dpr);
        tela.height = Math.round(altezza * dpr);
      }
      gl.viewport(0, 0, tela.width, tela.height);
      gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

      // L'STL e' con Z in alto, WebGL con Y in alto: la rotazione di
      // -90 gradi attorno a X rimette il pezzo in piedi.
      var mv = prodotto(trasla(0, 0, -distanza),
                 prodotto(ruotaX(-Math.PI / 2 + alzata),
                   prodotto(ruotaZ(azimut),
                     trasla(-misure.centro[0], -misure.centro[1],
                            -misure.centro[2]))));
      gl.uniformMatrix4fv(uMv, false, mv);
      gl.uniformMatrix4fv(uProiezione, false,
        prospettiva(1.0, larghezza / altezza,
                    Math.max(0.1, distanza - misure.raggio * 2),
                    distanza + misure.raggio * 3));
      gl.drawArrays(gl.TRIANGLES, 0, modello.pos.length / 3);
    }

    // Disegno su richiesta e non a 60 fotogrammi al secondo: un modello
    // fermo non ha motivo di tenere occupata la GPU.
    var inCoda = false;
    function ridisegna() {
      if (inCoda) return;
      inCoda = true;
      requestAnimationFrame(function () { inCoda = false; disegna(); });
    }

    var trascina = null;
    tela.addEventListener('pointerdown', function (e) {
      trascina = { x: e.clientX, y: e.clientY };
      tela.setPointerCapture(e.pointerId);
      tela.style.cursor = 'grabbing';
    });
    tela.addEventListener('pointermove', function (e) {
      if (!trascina) return;
      azimut -= (e.clientX - trascina.x) * 0.01;
      alzata += (e.clientY - trascina.y) * 0.01;
      alzata = Math.max(-1.55, Math.min(1.55, alzata));
      trascina = { x: e.clientX, y: e.clientY };
      ridisegna();
    });
    function fine(e) {
      if (!trascina) return;
      trascina = null;
      tela.style.cursor = 'grab';
      if (e.pointerId !== undefined && tela.hasPointerCapture &&
          tela.hasPointerCapture(e.pointerId)) {
        tela.releasePointerCapture(e.pointerId);
      }
    }
    tela.addEventListener('pointerup', fine);
    tela.addEventListener('pointercancel', fine);
    tela.addEventListener('wheel', function (e) {
      e.preventDefault();
      distanza *= e.deltaY > 0 ? 1.1 : 1 / 1.1;
      distanza = Math.max(distanzaIniziale * 0.4,
                          Math.min(distanzaIniziale * 3, distanza));
      ridisegna();
    }, { passive: false });

    // Con la tastiera: il visualizzatore non deve essere l'unico modo di
    // vedere il pezzo, ma chi ci arriva col tab deve poterlo girare.
    tela.tabIndex = 0;
    tela.addEventListener('keydown', function (e) {
      var passo = 0.12;
      if (e.key === 'ArrowLeft') azimut += passo;
      else if (e.key === 'ArrowRight') azimut -= passo;
      else if (e.key === 'ArrowUp') alzata = Math.max(-1.55, alzata - passo);
      else if (e.key === 'ArrowDown') alzata = Math.min(1.55, alzata + passo);
      else return;
      e.preventDefault();
      ridisegna();
    });

    window.addEventListener('resize', ridisegna);

    contenitore.insertBefore(tela, contenitore.firstChild);
    contenitore.classList.add('stl-viewer-attivo');

    // Il testo di riserva ha fatto il suo lavoro: adesso spiegherebbe come
    // fare a meno di quello che si sta guardando. Al suo posto resta la
    // didascalia, col link all'STL, che serve anche a visualizzatore
    // funzionante (si apre in una slicer).
    var riserva = contenitore.querySelector('p');
    if (riserva) {
      riserva.textContent = 'Trascina per ruotare, rotella per lo zoom, ' +
        'frecce da tastiera. Oppure ';
      link.textContent = 'scarica l\'STL';
      riserva.appendChild(link);
      riserva.appendChild(document.createTextNode('.'));
      riserva.style.fontSize = '0.9em';
      riserva.style.opacity = '0.75';
      riserva.style.margin = '0.6rem 0 0';
    }

    disegna();
  }

  function guasto(contenitore, motivo) {
    var p = document.createElement('p');
    p.className = 'stl-viewer-guasto';
    p.textContent = 'Il modello interattivo non e\' disponibile (' + motivo +
      '). Restano le immagini qui sopra e l\'STL da scaricare.';
    contenitore.appendChild(p);
  }

  function inizializza() {
    var contenitori = document.querySelectorAll('[data-stl-viewer]');
    for (var i = 0; i < contenitori.length; i++) {
      (function (c) {
        if (c.dataset.stlAvviato) return;
        c.dataset.stlAvviato = '1';
        // L'indirizzo dell'STL si legge dal link di riserva invece che da
        // un attributo: docmd riscrive gli href in percorsi relativi al
        // livello della pagina, un attributo dato no. Un solo indirizzo,
        // gia' corretto, e se cambia lo segue anche il visualizzatore.
        var link = c.querySelector('a[href$=".stl"]');
        if (!link) return;
        fetch(link.href)
          .then(function (r) {
            if (!r.ok) throw new Error('HTTP ' + r.status);
            return r.arrayBuffer();
          })
          .then(function (b) { avvia(c, leggiStl(b), link); })
          .catch(function (e) { guasto(c, e.message); });
      })(contenitori[i]);
    }
  }

  inizializza();
  if (!window.__stlViewerInSpa) {
    window.__stlViewerInSpa = true;
    document.addEventListener('docmd:page-mounted', inizializza);
    document.addEventListener('DOMContentLoaded', inizializza);
  }
})();
