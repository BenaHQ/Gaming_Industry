# Granchietto (titolo provvisorio)

Primo gioco di gruppo: un **platform 2D pixel-art subacqueo** fatto con **Godot 4**.
Il design completo (personaggi, nemici, boss, power-up) è in [`docs/GDD.md`](docs/GDD.md).

## Come aprirlo

1. Installate **Godot 4.3 o più recente** (versione standard, non .NET): <https://godotengine.org/download>
2. Avviate Godot → **Import** → selezionate `project.godot` in questa cartella.
3. Premete **F5** (Play). Si parte dal menu → Base sulla spiaggia.

## Cosa c'è nella bozza

- **Base sulla spiaggia**: Tartaruga mercante (vende chele in cambio di perle) e Manta che porta al livello.
- **Livello 1 – Barriera corallina**: pesci palla, meduse, piranha, ricci di mare, perle,
  cavalluccio marino (checkpoint), power-up **Dash** e **Deltaplano** nello zaino,
  **Chela Martello** per rompere il muro di roccia crepata e arrivare alla **conchiglia del tesoro**.
- Fisica diversa fra terra e acqua, chele intercambiabili, HUD, pausa, morte/checkpoint.

Controlli: **A/D** muovi · **Spazio** salta (in acqua anche a mezz'aria; tieni premuto per planare) ·
**J** chela · **K** dash · **Q/E** cambia chela · **W** interagisci · **Esc** pausa · **R** ricomincia.

## Struttura

```
assets/sprites/   sprite PNG segnaposto (generati da tools/gen_sprites.py)
scenes/           scene Godot (.tscn): player, enemies, objects, npc, levels, ui
scripts/          codice GDScript, stessa divisione delle scene
  autoload/game_state.gd   stato globale: perle, vita, chele, zaino, checkpoint, input
  level/level.gd           costruisce i livelli da una mappa ASCII
docs/GDD.md       documento di design
tools/            script di supporto
```

## Modificare / creare un livello

I livelli sono disegnati con caratteri: aprite `scenes/levels/level_01_reef.tscn`,
selezionate il nodo radice e modificate la proprietà **Map** nell'Inspector.
La legenda completa è in cima a `scripts/level/level.gd` (`#` roccia, `=` sabbia, `S` partenza,
`o` perla, `p` pesce palla, `m` medusa, `r` piranha, `X` roccia crepata, `T` tesoro, …).
Per un livello nuovo: duplicate la scena, cambiate mappa, nome e colori.

## Grafica

Gli sprite attuali sono **segnaposto**. Per sostituirli basta salvare un PNG con lo stesso nome
(e la stessa griglia di frame, es. `crab.png` = 4 frame da 16×16) in `assets/sprites/`.
Per rigenerare i segnaposto: `python3 tools/gen_sprites.py` (serve Pillow).

## Lavorare in gruppo con Git

- `main` = versione che funziona sempre. Si lavora su branch (`feature/nome-cosa`) e si apre una Pull Request.
- La cartella `.godot/` è ignorata (cache locale). I file `.import` invece vanno committati.
- Evitate di modificare la stessa scena `.tscn` in due contemporaneamente: è il punto dove nascono i conflitti.
