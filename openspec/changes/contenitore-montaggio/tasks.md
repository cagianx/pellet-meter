# Tasks

## 1. Parametri

- [x] 1.1 Peso stimato del dispositivo e portata del biadesivo come parametri, da cui ricavare l'area minima di incollaggio
- [x] 1.2 Parametri del tappo e dei dentini di ritenuta, legati al `gioco` esistente invece di introdurre una seconda tolleranza

## 2. Modello

- [x] 2.1 Tappo USB-C con cordino stampato, che resta vincolato al contenitore
- [x] 2.2 Superficie di incollaggio piana e continua sul fondo
- [x] 2.3 Dentini a scatto sulla battuta e finestre corrispondenti nel labbro — invertiti rispetto al design, vedi la decisione aggiornata: un incavo nella battuta lascerebbe 0,3 mm di parete
- [x] 2.4 Tacca per fare leva con l'unghia, perche' una chiusura che tiene deve anche poter essere aperta

## 3. Verifica

- [x] 3.1 `check_case.py` verifica che l'area di incollaggio superi il minimo calcolato dal peso
- [x] 3.2 `check_case.py` verifica che il tappo esista e sia collegato al corpo, non un solido separato
- [x] 3.3 Le quote dichiarate restano coerenti con il solido dopo le aggiunte

## 4. Documentazione

- [x] 4.1 Spiegare in docs/ che il contenitore si monta capovolto rispetto a come e' disegnato
- [x] 4.2 Scrivere in docs/ il limite di temperatura del materiale e il suo effetto sul biadesivo
