# Pipeline de produção 3D — Blender

Este documento define como produzir assets originais para Vice City Mobile. Não usar modelos extraídos de jogos comerciais nem personagens/marcas protegidos.

## Versão e formato

- Blender 4.x ou superior.
- Exportação principal: glTF 2.0 Binary (.glb).
- Aplicar transformações antes da exportação: Rotation e Scale.
- Unidade de trabalho: 1 unidade Blender = 1 metro.
- Orientação glTF: Y para cima; conferir a orientação do objeto após exportar.

## Personagens

- Criar personagens originais com anatomia e silhueta legíveis.
- Rig humanoide com nomes consistentes para quadril, coluna, braços, pernas, mãos e pés.
- Ações separadas: Idle, Walk, Run, Jump e Interact.
- Usar deformação por pesos; testar ombros, cotovelos, joelhos e quadril.
- Exportar malha, armature e animações no mesmo GLB.
- Evitar excesso de polígonos; priorizar silhueta e normal maps.

## Veículos

- Separar carroceria, rodas, vidros, faróis e peças móveis.
- Origem do veículo no centro do eixo traseiro ou no centro do chassi, conforme o controlador.
- Rodas com pivôs individuais e nomes previsíveis: wheel_fl, wheel_fr, wheel_rl, wheel_rr.
- Criar colisores simples separados da malha visual.
- Testar esterçamento, rotação das rodas e escala no Three.js.

## Edifícios e ambiente

- Modelar fachadas com variação de volumes, sacadas, marquises e coberturas.
- Preferir bevels controlados e formas orgânicas; evitar arquitetura composta apenas por cubos.
- Criar módulos reutilizáveis de portas, janelas, postes, bancos, placas e vegetação.
- Separar colisão da geometria visual.
- Usar atlas de textura e materiais compartilhados para reduzir draw calls.

## Otimização Android

- Aplicar LODs: alto, médio e baixo.
- Reduzir materiais por objeto e evitar transparências desnecessárias.
- Texturas: 1K para assets comuns; 2K somente para peças principais.
- Preferir formatos de textura comprimidos no pipeline de produção.
- Remover câmeras, luzes e objetos de referência da exportação.
- Validar tamanho do GLB e memória de GPU em aparelho Android real.

## Organização sugerida

```text
assets/
  characters/
  vehicles/
  buildings/
  vegetation/
  props/
  textures/
```

## Checklist antes de enviar

- [ ] Escala e orientação verificadas.
- [ ] Normais corretas e sem faces invertidas.
- [ ] Materiais PBR conferidos no glTF Viewer.
- [ ] Armature e animações testadas, quando aplicável.
- [ ] LODs e colisores preparados.
- [ ] GLB testado no navegador Android.
- [ ] Licença e autoria do asset documentadas.

**Importante:** arquivos .blend só devem entrar no repositório quando forem assets reais criados ou licenciados. Não criar arquivos Blender vazios apenas para preencher pastas.