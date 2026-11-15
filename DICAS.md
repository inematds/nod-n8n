# 25 dicas para começar

São sugestões editoriais baseadas na documentação, não relatos de uso. As fontes Fxx remetem à tabela e aos caminhos em [FATOS.md](FATOS.md).

## Antes de instalar

1. **Escolha onde os dados ficam.**  
   Escolha desktop para usar na sua máquina ou servidor para acessar de outros dispositivos.  
   A documentação diz que conectar o desktop ao servidor não migra seus dados locais.  
   (Fonte: FATOS.md, F03, F10, F55.)

2. **Confira o seu sistema.**  
   Confira os requisitos antes de baixar. No desktop, você não precisa instalar Docker;  
   Windows local pede WSL 2 e Linux local pede virtualização e secret store.  
   (Fonte: FATOS.md, F03–F06.)

3. **Comece como pesquisa.**  
   Trate o research preview como algo a acompanhar. Nossa sugestão é começar com leitura e rascunhos,  
   pois a documentação diz que o trust check pode errar.  
   (Fonte: FATOS.md, F02, F34–F35.)

## Escolher o modelo

4. **Confira a conexão, não só o nome.**  
   Veja a lista em Settings → Models. Um modelo no catálogo não prova que sua conta pode usá-lo.  
   Se escolher ChatGPT, a documentação exige Plus ou Pro.  
   (Fonte: FATOS.md, F19–F21.)

5. **Escolha com atenção à segurança.**  
   A documentação relata acerto em todas as 240 decisões para GPT-6.1 Sol e Claude Opus 5.5.  
   Claude Haiku 5.5 deixou passar 8 ações inseguras nesse teste; não generalize o resultado.  
   (Fonte: FATOS.md, F52.)

6. **Local precisa de tools e contexto.**  
   Para Ollama ou outro OpenAI-compatible, confira tool calls e pelo menos 64.000 tokens de contexto.  
   Confira também qual conexão faz o trust check: ela pode enviar dados a outro serviço.  
   (Fonte: FATOS.md, F22–F23.)

## Ligar os apps sem abrir demais

7. **Conecte só o necessário.**  
   Nossa sugestão é ligar apenas o app da primeira tarefa. Você pode pular conexões no onboarding.  
   Leia o consentimento: uma permissão pode cobrir sua caixa de e-mail inteira.  
   (Fonte: FATOS.md, F24–F25.)

8. **Confira qual conta está ativa.**  
   Em Apps, revise identidades e permissões antes de pedir qualquer ação.  
   Use plus/Add account quando disponível; Notion, Linear e n8n usam MCP próprios.  
   (Fonte: FATOS.md, F24–F25.)

9. **Pegadinha: nem tudo fica local.**  
   Não trate “roda no seu computador” como “nada vai para a nuvem”. A doc diz que pedidos de apps  
   passam pela n8n e pelo Composio por padrão. ZDR tem escopo e não reduz permissões.  
   (Fonte: FATOS.md, F26–F27, F55.)

## Segurança e privacidade

10. **Desligue Share usage data.**  
   Abra Settings → Privacy & data e desligue Share usage data se você não quiser novos envios.  
   Ele vem ligado para novos usuários; desligar não apaga o que já foi enviado.  
   (Fonte: FATOS.md, F53.)

11. **Mantenha traces desligados no começo.**  
   Nossa sugestão é manter Share conversation traces desligado enquanto você avalia o produto.  
   O controle é separado e já vem desligado. A remoção de dados pessoais pode deixar detalhes passar.  
   (Fonte: FATOS.md, F54.)

12. **Defina seu limite mensal.**  
   Com um API model selecionado, abra Usage e ajuste o limite ao que você aceita gastar.  
   A doc informa US$ 200 no setup atual; instalações anteriores podem não ter limite. Plano e uso sem preço têm regras distintas.  
   (Fonte: FATOS.md, F57–F59.)

13. **Use o formulário do Vault.**  
   Digite senhas e códigos nos campos privados, não na conversa. Confira conta e site.  
   Para pagar, você aprova cada pagamento e informa o código de segurança, que nunca é salvo.  
   (Fonte: FATOS.md, F31–F33.)

14. **Não ligue tudo no primeiro dia.**  
   Nossa sugestão: adie cartões, contas extras, Include sensitive details e permissões para agir sozinho.  
   Comece com rascunhos; confira preparação automática em Settings → Notifications, pois as páginas divergem sobre o padrão.  
   (Fonte: FATOS.md, F25, F32, F35, F45, F62.)

15. **Pegadinha: a IA participa da decisão.**  
   O trust check roda no servidor, mas seu julgamento também usa modelo.  
   Não confunda controle fora do prompt com decisão infalível. Peça aprovação antes de ações que você quer revisar.  
   (Fonte: FATOS.md, F34–F36.)

## Deixar 24/7

16. **Dimensione a VPS.**  
   Comece pela referência da doc: Linux AMD64/ARM64, 2 núcleos, 8 GB e 50 GB.  
   Use o checklist do servidor; tarefas simultâneas e modelos locais podem exigir mais capacidade.  
   (Fonte: FATOS.md, F07–F08.)

17. **Mantenha o Mac mini acordado.**  
   Reserve memória para Docker e para macOS. Ative o início do Docker Desktop após login.  
   Depois de reiniciar ou faltar energia, entre na conta e confira que Nod voltou.  
   (Fonte: FATOS.md, F09.)

18. **Use túnel e proteja o token.**  
   Para acesso privado, siga o túnel SSH do checklist e mantenha a conexão aberta.  
   O token dá acesso completo ao assistente; não o trate como um link de leitura. Domínio público exige HTTPS.  
   (Fonte: FATOS.md, F10, F14–F16.)

19. **Guarde um backup recuperável.**  
   Antes de atualizar, use o procedimento de backup da doc. Guarde fora do servidor, cifrado e restrito.  
   Inclua a Vault key e a revisão correspondente; só copiar o banco não recupera as credenciais.  
   (Fonte: FATOS.md, F17–F18.)

## Primeiras tarefas que valem a pena

20. **Comece por um resumo privado.**  
   Use o pedido de rotina de e-mail ou brief de reunião em TAREFAS.md.  
   Nossa sugestão é revisar o texto antes de liberar envios. A doc apresenta essas tarefas como exemplos.  
   (Fonte: FATOS.md, F35, F63.)

21. **Faça uma vigilância simples.**  
   Peça um schedule de preço e proíba compras no próprio pedido. Confira fuso e próxima execução.  
   Em Scheduled, use Run now e leia o resultado; a máquina precisa continuar ligada.  
   (Fonte: FATOS.md, F56, F60–F61.)

## Memória

22. **Revise o que ele aprendeu.**  
   Abra Settings → Memory para ver a fonte, editar ou esquecer notas.  
   Notas pessoais vêm do que você fornece; o estilo dos seus e-mails enviados é um aprendizado separado.  
   (Fonte: FATOS.md, F44–F45.)

23. **Entenda Let go e Skills.**  
   Let go arquiva notas substituídas ou expiradas; você pode restaurar ou esquecer.  
   Há manutenção de hora em hora. Confira Skills aprendidas: elas podem conter erro e nunca dão permissão para agir.  
   (Fonte: FATOS.md, F46–F48.)

## Onde ele ainda falha

24. **Pegadinha: benchmark não é garantia.**  
   Os 98% e zero ações inseguras são de contas e sites simulados com GPT-6.1 Sol.  
   São 226 tarefas repetidas 3 vezes. Zero injeções de memória também não significa zero influência do e-mail.  
   (Fonte: FATOS.md, F49–F51.)

25. **Confira antes de repetir.**  
   Se um pagamento terminar como Result unknown, confira o pedido antes de tentar de novo.  
   Schedules param com a máquina; WhatsApp QR pode sofrer restrições. Não dependa de hosted futuro.  
   (Fonte: FATOS.md, F29, F33, F56.)
