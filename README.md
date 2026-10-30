# Monitor Task Switcher

Layout de Alt+Tab para o KDE Plasma 6.8, com miniaturas do KWin agrupadas por monitor. O layout exibe uma caixa por monitor conectado, mesmo sem janelas, na ordem da disposição física configurada no KDE. A faixa de monitores rola horizontalmente; as miniaturas de cada caixa formam uma grade com rolagem vertical.

## Instalar

Para criar um pacote que pode ser instalado pelas configurações do seletor de tarefas, execute:

```sh
make package
```

O arquivo `monitor_task_switcher.kwinswitcher` pode ser selecionado na opção de instalação de um layout a partir de um arquivo.

Na raiz deste projeto:

```sh
make install
```

O comando instala o pacote na primeira vez e substitui a instalação existente nas execuções seguintes. Em **Configurações do Sistema > Gerenciamento de janelas > Seletor de tarefas**, escolha **Monitor Task Switcher** somente como layout **Principal**. O layout **Alternativo** pode continuar como estava.

O pacote não cria nem altera atalhos. Alt+Tab, Alt+Shift+Tab e os atalhos equivalentes configurados no KDE continuam usando as ações nativas do KWin. As setas navegam espacialmente dentro do painel; um clique ativa uma janela, e o botão no canto a fecha quando permitido. Selecionar uma janela de outra atividade solicita sua ativação ao KWin. Miniaturas minimizadas podem manter o último quadro disponível; o ícone e o título permanecem visíveis.

## Atualizando para novas versões

Basta executar o comando `make install` para substituir a versão já instalada.

Depois de instalar uma nova versão, é necessário reiniciar o Plasma Desktop para que a mudança surta efeito. Isso é uma restrição do KDE, que mantém um cache do Task Switcher em memória até que o Plasma Desktop seja reiniciado. O logout e o login na sessão do desktop já são suficientes para carregar a nova versão.

## Uninstall

Selecione outro layout como seletor principal. Se tiver alterado os filtros acima, restaure-os conforme sua preferência. Depois, remova o pacote com:

```sh
make uninstall
```

Isso não modifica os atalhos globais nem o layout alternativo.