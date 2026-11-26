# Design

## Context

Vedi proposal.md. Oggi i workflow partono da `kicad/kicad:10.0.8-full` e ci
installano sopra quello che serve con `apt-get`, in modo condizionale. La
condizione e' il punto fragile che ha gia' ceduto.

## Goals / Non-Goals

**Goals:**
- Una sola definizione degli strumenti, versionata.
- Chi sviluppa puo' avere esattamente l'ambiente della CI senza installare
  niente.
- Niente installazioni al volo nei workflow: se uno strumento manca,
  manca nel `Dockerfile`, dove si vede.

**Non-Goals:**
- Un'immagine che contenga **tutto**, firmware compreso. Vedi sotto.
- Sostituire podman o docker con un devcontainer completo: chi vuole un
  devcontainer puo' costruirlo sopra questa immagine.

## Decisions

- **Base `kicad/kicad:10.0.8-full`.** E' la stessa versione usata in
  sviluppo, ed e' gia' la scelta del workflow `hardware`: cambiarla
  significherebbe rischiare che la CI veda un KiCad diverso, che e'
  esattamente il problema che quella scelta evitava.

- **Il firmware resta su `espressif/idf:v5.5`, fuori da questa immagine.**
  Unire le due catene raddoppierebbe la dimensione (ESP-IDF porta il
  toolchain RISC-V completo) e accoppierebbe due cose che cambiano per
  ragioni diverse: un aggiornamento di KiCad ricostruirebbe anche il
  compilatore. Il problema che questo change risolve — tre definizioni
  divergenti — sul firmware non esiste: e' gia' un'immagine sola e
  fissata.

- **Pubblicata su GHCR, costruita solo quando il `Dockerfile` cambia.**
  Ricostruirla a ogni commit costerebbe minuti a ogni push per un
  contenuto che cambia di rado. Il workflow che la costruisce si attiva
  sul percorso del `Dockerfile`.

- **Pacchetto privato con `credentials` nel job, non pacchetto pubblico.**
  Un pacchetto GHCR nasce privato, e renderlo pubblico e' un passo manuale
  nell'interfaccia di GitHub. Dichiarando le credenziali nel blocco
  `container` il `GITHUB_TOKEN` basta a scaricarla, e il repo resta
  utilizzabile da chi lo clona senza che nessuno debba ricordarsi di una
  spunta.

- **Shell dichiarata comunque.** `defaults.run.shell: bash` resta anche con
  l'immagine nostra: e' una riga che toglie di mezzo una scoperta, e la
  scoperta sbagliata e' gia' costata.

- **Node dentro l'immagine**, anche se il job che costruisce il sito gira
  sul runner con `setup-node` e la cache di npm. Serve a chi sviluppa: con
  una sola immagine si fa tutto, render e sito, senza installare Node.

## Risks / Trade-offs

- **L'immagine e' grossa** (KiCad full e' alcuni GB). Per la CI cambia
  poco, perche' oggi scarica gia' quella di KiCad. In locale e' un
  download una tantum, ed e' facoltativo: gli strumenti si possono
  installare a mano come adesso.

- **Un livello in piu' da tenere aggiornato.** Mitigato dal fatto che la
  ricostruzione e' automatica e che le versioni restano fissate nel
  `Dockerfile`, dove si leggono.

- **Primo giro a vuoto**: finche' l'immagine non e' pubblicata, i workflow
  non possono usarla. Per questo i task la pubblicano prima e la adottano
  dopo, in due passi.

## Open Questions

Nessuna.
