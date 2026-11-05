# Granchietto — Game Design Document (bozza)

> Titolo provvisorio. Documento vivo: aggiungete, cancellate, discutete.
> ✅ = già presente nella bozza Godot · 🔲 = da fare

## 1. Concept

**Genere:** platform 2D a scorrimento laterale
**Stile:** pixel art (risoluzione interna 320×180, 16 px per tile)
**Protagonista:** Granchietto, un piccolo granchio che parte dalla sua base sulla spiaggia ed esplora i fondali.
**Ciclo di gioco:** base sulla spiaggia → livello sottomarino → tesoro → si torna alla base a spendere le perle → livello successivo.

## 2. Telecamera

Godot 2D usa già una proiezione **ortografica** ✅ (scelta attuale: pixel art pulita, collisioni semplici).
In alternativa, in futuro: **2.5D in prospettiva** (Camera3D con sprite 3D / mondo 3D e movimento solo su X/Y) — decisione da prendere in gruppo. 🔲

## 3. Il protagonista: Granchietto

| Movimento | Stato |
|---|---|
| Camminare, saltare (salto variabile, coyote time, jump buffer) | ✅ |
| Sott'acqua: gravità ridotta + 2 "bracciate" (salti extra) | ✅ |
| Pestare i nemici dall'alto | ✅ |
| Attacco con la chela | ✅ |

### 3.1 Power-up 1: le chele (si cambiano in base a quelle acquistate)

| Chela | Effetto | Come si ottiene | Stato |
|---|---|---|---|
| Pinza | base, 1 danno | iniziale | ✅ |
| Tenaglia | portata lunga | Tartaruga mercante (10 perle) | ✅ |
| Martello | 2 danni, rompe le rocce crepate, sgonfia i pesci palla | trovata nel Livello 1 / mercante (15 perle) | ✅ |
| Idee: chela elettrica, chela-rampino, chela-scudo… | | | 🔲 |

Cambio chela: **Q / E** (o dorsali del pad).

### 3.2 Power-up 2: lo zaino (backpack)

| Oggetto | Effetto | Stato |
|---|---|---|
| Getto a reazione (Dash) | scatto orizzontale, 1 volta in aria | ✅ |
| Deltaplano | tieni premuto SALTO in caduta per planare | ✅ |
| Oggetti di supporto (bolla d'aria, lanterna per gli abissi, bomba d'inchiostro…) | | 🔲 |

## 4. Ambientazione

- **Base sulla spiaggia** (hub): Tartaruga mercante, Manta per partire. ✅
- **Livelli sott'acqua:**
  1. Barriera corallina ✅ (bozza giocabile)
  2. Relitto (livello intero dentro una nave affondata) 🔲
  3. Abissi (buio, Angler fish con la lucina) 🔲
  4. Dentro la Balena (livello intero) 🔲
- **Tesoro:** a fine livello una conchiglia che si apre. ✅

## 5. Nemici

| Nemico | Comportamento | Stato |
|---|---|---|
| Pesce palla | pattuglia, si gonfia di spine (immune tranne al Martello) | ✅ |
| Medusa | fluttua su e giù, punge (non si può pestare) | ✅ |
| Piranha | pattuglia e carica se ti vede | ✅ |
| Riccio di mare (ostacolo) | danno al contatto | ✅ |
| Angler fish | negli abissi, la lucina attira/illumina | 🔲 |
| Pesce scorpione | spine velenose, immobile/mimetico | 🔲 |
| Polipo | spruzza inchiostro (oscura lo schermo) | 🔲 |
| Anguilla elettrica | esce dalle tane, scarica elettrica a tempo | 🔲 |
| Barracuda | velocissimo, attraversa lo schermo | 🔲 |

## 6. Personaggi

| Personaggio | Ruolo | Stato |
|---|---|---|
| Manta | mezzo di trasporto fra base e livelli | ✅ |
| Cavalluccio marino | aiutante: checkpoint + consigli | ✅ |
| Tartaruga | mercante (vende chele per perle) | ✅ |
| Sirena | ruolo da decidere (missioni secondarie? storia?) | 🔲 |
| Delfino | idea: livello "in groppa" a scorrimento veloce | 🔲 |
| Stella marina | idea: collezionabile / vite extra / guida | 🔲 |

## 7. Boss

| Boss | Idea | Stato |
|---|---|---|
| Kraken | tentacoli da schivare/colpire | 🔲 |
| Squalo – Megalodonte | inseguimento | 🔲 |
| King Crab (o trasformazione del Krabbo) | duello chela contro chela | 🔲 |
| Leviatano | boss finale | 🔲 |

## 8. Storia

🔲 Da scrivere insieme. Spunti: perché Granchietto lascia la spiaggia? Chi ha rubato il tesoro? Il Krabbo è il rivale?

## 9. Controlli (bozza)

| Azione | Tastiera | Pad |
|---|---|---|
| Muovi | A/D o frecce | stick / croce |
| Salta / bracciata / plana (tieni premuto) | Spazio o Z | A |
| Chela | J o X | X |
| Dash | K, C o Shift | RB |
| Cambia chela | Q / E | LB / Y |
| Interagisci (manta, tartaruga) | W o ↑ | B |
| Pausa | Esc / P | Start |
| Ricomincia livello | R | Back |
