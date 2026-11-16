# Vice City Mobile

Projeto independente de jogo de mundo aberto 3D para navegador e Android. Não é um produto oficial da Rockstar Games e não utiliza arquivos proprietários de GTA.

## Executar

Requer Node.js 20.19+ ou 22.12+.

```bash
npm install
npm run dev -- --host 0.0.0.0
```

Abra o endereço indicado pelo Vite no navegador do celular ou computador.

## Build de produção

```bash
npm run build
npm run preview
```

## Controles

- Celular: joystick virtual no canto inferior esquerdo.
- Câmera: arraste a área livre da tela.
- Correr: botão CORRER.
- Entrar/sair do carro: aproxime-se e toque ENTRAR.
- Teclado: WASD ou setas; Shift para correr; E para entrar/sair do veículo.

## Sistemas incluídos nesta primeira entrega

- Cena Three.js com ilha extensa, oceano, atmosfera e iluminação.
- Malha urbana procedural com avenidas curvas, calçadas, edifícios arredondados e palmeiras.
- Personagem humanoide animado carregado como GLB externo (animações Idle/Walk/Run).
- Veículo dirigível, câmera em terceira pessoa e HUD móvel.
- Minimap, relógio do jogo e controles touch sem seleção de texto.

## Próximas etapas de produção

1. Substituir o modelo de demonstração por personagem original licenciado e com rig humanoide.
2. Substituir a cidade procedural por setores artísticos detalhados, com interiores e pontos de interesse.
3. Adicionar tráfego, pedestres, missões, salvamento e áudio espacial.
4. Criar assets próprios no Blender e otimizar GLB, texturas, LOD e colisões para Android.

O modelo humanoide de demonstração é carregado de um exemplo público do Three.js; é necessário acesso à internet para baixá-lo.