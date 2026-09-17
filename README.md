# Hell Fire Department

Protótipo de FPS em Godot 4.7.

## Estrutura

- `scenes/levels`: fases jogáveis. `main` é a cena inicial; `nuketown` é uma fase alternativa.
- `scenes/player`: cena reutilizável do jogador.
- `scripts/player`, `scripts/weapons` e `scripts/ui`: lógica separada por responsabilidade.
- `resources/weapons`: dados configuráveis das armas (`WeaponData`).
- `GLB format`: modelos e texturas importados já usados pelas cenas.

## Controles

- WASD: mover; Espaço: pular; mouse esquerdo: atirar.
- R: recarregar; Tab: trocar arma; [ e ]: ajustar FOV de teste.

Abra `project.godot` no Godot 4.7 e execute a cena principal.
