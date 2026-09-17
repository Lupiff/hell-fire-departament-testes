# Hell Fire Department

Protótipo de FPS em Godot 4.7.

## Estrutura

- `scenes/levels`: fases jogáveis. `nuketown` é a cena inicial; `main` é uma fase menor de teste.
- `scenes/player`: cena reutilizável do jogador.
- `scripts/player`, `scripts/weapons` e `scripts/ui`: lógica separada por responsabilidade.
- `resources/weapons`: dados configuráveis das armas (`WeaponData`).
- `GLB format`: modelos e texturas importados já usados pelas cenas.

## Controles

- WASD: mover; Espaço: pular; mouse esquerdo: atirar.
- R: recarregar; Tab: trocar arma; [ e ]: ajustar FOV de teste. O HUD mostra munição atual / capacidade do pente, e a retícula é um ponto branco central.

O som de disparo da MP40 fica em `assets/audio/mp40_fire.mp3` e é configurado no recurso da arma.

Abra `project.godot` no Godot 4.7 e execute a cena principal.
