# Monitor Task Switcher

Layout de Alt+Tab para KDE Plasma 6.8 com miniaturas do KWin agrupadas por monitor. O layout exibe uma caixa por monitor conectado, mesmo sem janelas, na ordem da disposicao fisica configurada no KDE. A faixa de monitores rola horizontalmente; as miniaturas de cada caixa formam uma grade com rolagem vertical.

## Instalar

Para criar um pacote que pode ser instalado pelas configuracoes do seletor de tarefas, execute:

```sh
make package
```

O arquivo `monitor_task_switcher.kwinswitcher` pode ser selecionado na opcao de instalacao de um layout a partir de arquivo.

Na raiz deste projeto:

```sh
make install
```

O comando instala o pacote na primeira vez e substitui a instalacao existente nas execucoes seguintes. Em **Configuracoes do Sistema > Gerenciamento de janelas > Seletor de tarefas**, escolha **Monitor Task Switcher** somente como layout **Principal**. O layout **Alternativo** pode continuar como estava.

Apos editar `contents/ui/main.qml`, execute `make install` novamente e feche e reabra o Alt+Tab. Confirme o layout principal selecionado com `kreadconfig6 --file kwinrc --group TabBox --key LayoutName`: o resultado deve ser `monitor_task_switcher`. Se aparecer `clay_grid`, o KWin ainda esta usando outro layout; selecione **Monitor Task Switcher** nas Configuracoes do Sistema. `make uninstall` remove o pacote, portanto suas alteracoes no QML deixam de aparecer no Alt+Tab ate uma nova instalacao e selecao.

O KWin pode manter o componente QML anterior em memoria mesmo depois de `make install` e de uma recarga de configuracao. Nesta sessao isso foi confirmado: o arquivo instalado tinha `columns: 10`, mas o KWin ainda executava o trecho antigo. Para garantir que uma alteracao no QML apareca, encerre a sessao KDE e entre novamente apos instalar. Nao reinicie o KWin Wayland dentro da sessao.

No mesmo painel, configure os filtros do seletor principal:

- Janelas apenas do **desktop virtual atual** e de **todas as atividades**.
- Janelas de **todas as telas**, inclusive **minimizadas** e presentes em todos os desktops.
- **Nao** incluir "Mostrar area de trabalho" no ciclo e **nao** agrupar minimizadas em separado, para manter a ordem de uso recente.

Esses filtros sao aplicados pelo KWin antes de expor as janelas ao layout. O pacote nao consegue mostrar uma janela excluida por eles. Na configuracao local examinada, o ciclo ainda inclui "Mostrar area de trabalho" e agrupa minimizadas; ajuste ambas as opcoes para obter o comportamento descrito. Janelas especiais ou marcadas para nao aparecer no Alt+Tab continuam excluidas pelo KWin.

O pacote nao cria nem altera atalhos. Alt+Tab, Alt+Shift+Tab e os atalhos equivalentes configurados no KDE continuam usando as acoes nativas do KWin. As setas navegam espacialmente dentro do painel; clique ativa uma janela, e o botao no canto fecha uma janela quando permitido. Selecionar uma janela de outra atividade solicita sua ativacao ao KWin. Miniaturas minimizadas podem manter o ultimo quadro disponivel; o icone e o titulo permanecem visiveis.

## Verificar

Abra o seletor com janelas em dois monitores, incluindo uma minimizada, outra em todos os desktops e uma de outra atividade. Confira a caixa vazia ao deixar um monitor sem janelas, a selecao com Tab/Shift+Tab e setas e a rolagem de cada caixa. Alteracoes na disposicao de monitores durante um Alt+Tab aberto aparecem na proxima abertura.

## Reverter

Selecione novamente o layout anterior (nesta sessao, **Clay Grid**) para o seletor principal. Se tiver mudado os filtros acima, restaure-os conforme sua preferencia. Depois remova o pacote com:

```sh
make uninstall
```

Isso nao modifica os atalhos globais nem o layout alternativo.