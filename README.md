# Monitor Task Switcher

Layout de Alt+Tab para KDE Plasma 6.8 com miniaturas do KWin agrupadas por monitor. O layout exibe uma caixa por monitor conectado, mesmo sem janelas, na ordem da disposicao fisica configurada no KDE. A faixa de monitores rola horizontalmente; as miniaturas de cada caixa formam uma grade com rolagem vertical.

## Instalar

Na raiz deste projeto:

```sh
kpackagetool6 -t KWin/WindowSwitcher -i "$PWD"
```

Em **Configuracoes do Sistema > Gerenciamento de janelas > Seletor de tarefas**, escolha **Monitor Task Switcher** somente como layout **Principal**. O layout **Alternativo** pode continuar como estava. Para instalar uma versao atualizada, use `kpackagetool6 -t KWin/WindowSwitcher -u "$PWD"`.

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
kpackagetool6 -t KWin/WindowSwitcher -r monitor_task_switcher
```

Isso nao modifica os atalhos globais nem o layout alternativo.