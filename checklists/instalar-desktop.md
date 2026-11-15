# Checklist — instalar no desktop

Procedimento para você executar depois. Esta fase do kit não instala nem inicia o Nod. As fontes Fxx estão em [FATOS.md](../FATOS.md).

- [ ] Confira que você aceita o estágio de prévia de pesquisa. (F02)
- [ ] Mac: confira macOS 14 ou posterior e se o processador é Apple silicon ou Intel. (F03)
- [ ] Windows: confira Windows 11 x64; para assistente local, WSL 2, virtualização e 20 GB livres. (F04)
- [ ] Linux: confira x64, Flatpak e secret store desbloqueado; para local, virtualização e acesso a `/dev/kvm`. Não há desktop Linux ARM publicado. (F03–F04)
- [ ] Abra o [repositório oficial](https://github.com/n8n-io/nod) e vá a Releases. Escolha os arquivos do seu sistema. Aplicativo e ambiente local somam cerca de 1,8 GB de download no Mac e 2,1 GB no Windows; mantenha a internet conectada. (F05)
- [ ] Mac: abra o DMG correto, arraste Nod para Applications, abra e confirme Open. (F05)
- [ ] Windows: execute o instalador x64 e confira n8n GmbH como editor. Siga o setup de WSL se solicitado; se reiniciar, abra Nod novamente. (F05)
- [ ] Linux: baixe todas as partes `nod-linux-x64.flatpak.partNN` e `SHA256SUMS-linux-x64` da mesma release, em pasta vazia. Junte as partes, confira todos os checksums e só então instale o Flatpak. Siga os comandos da documentação oficial; mantenha o secret store desbloqueado. (F04–F05)
- [ ] Escolha Get started para local ou Connect to a server para endereço e token existentes. Desktop local não precisa de Docker instalado por você. (F04, F06)
- [ ] No local, mantenha internet durante o download do runtime. Escolha o modelo e confira sua conexão; e-mail e perguntas pessoais são opcionais. (F06, F19–F23)
- [ ] Complete o [checklist de segurança](seguranca-primeiro-dia.md) antes de conectar mais apps.
- [ ] Se depender de schedules, confira Open at login e mantenha a máquina acordada. Fechar a janela mantém o tray/menu; Quit Nod para o assistente local. (F56)
- [ ] Como conferência sugerida pelo kit, use o pedido de resumo em [TAREFAS.md](../TAREFAS.md) e revise o registro em Usage. (F35, F40, F63)

Fonte principal: `docs/src/content/docs/get-started/install-desktop.mdx`. Consulte a [documentação oficial](https://nod.n8n.io/docs/) antes de executar os passos.
