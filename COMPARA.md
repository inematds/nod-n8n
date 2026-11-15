# Nod × Instinct × Meta Muse × OpenAI dots

Comparação da documentação do Nod, com consulta registrada em 11/10/2026. Não é pesquisa independente. “A doc não diz” não significa recurso ausente.

| Critério | Nod | Instinct | Meta Muse | OpenAI dots |
| --- | --- | --- | --- | --- |
| Onde roda | Seu computador ou hospedagem própria | Serviço do fornecedor, conectado aos seus apps e dispositivos | Máquina virtual dedicada no serviço da Meta | A doc não diz |
| Quem acessa dados | Você e operador da hospedagem; n8n processa tráfego gerenciado padrão e compartilhamentos descritos | Segundo a doc, os termos concedem licença perpétua e irrevogável, inclusive para treinamento | Meta, para suporte, segurança ou operação | A doc não diz |
| Modelo | Você escolhe o provedor | A doc não diz | Modelo da Meta | Modelos da OpenAI |
| Regras fora do modelo | Revisão de permissão no servidor; usa modelo e pode errar | A doc cita relato de envio de e-mail sem perguntar | Processo separado de permissões | Há regras; a doc não diz como são impostas |
| Segredos fora do modelo | Entrada privada e mascaramento; servidor lê durante uso | A doc não diz | Marcadores substituídos pelos segredos na borda da rede | A doc não diz |
| Registro de ações | Página “Usage” | A doc não diz | Registro completo de auditoria | Visualização de atividades |
| Limite de gasto com modelo | Limite mensal | A doc não diz | A doc não diz | A doc não diz |
| Código aberto | Apache 2.0 | Não | Não | Não |
| Pagamentos | Cartão no cofre; não impõe valor ao emissor | A doc não diz | Cartões de uso único vinculados a comerciante e valor | A doc não diz |

Sobre o Instinct, a fonte usa a expressão “perpetual and irrevocable” para a licença e cita reportagem sobre o envio de e-mail sem perguntar. A documentação também destaca vantagens da Meta Muse: cartões de uso único, isolamento de segredos na borda da rede e recompensa por falhas de até US$ 300 mil; o Nod recebe relatos privados sem recompensa publicada.

Fonte: `docs/src/content/docs/trust/compare.mdx`, no clone de referência; [FATOS.md](FATOS.md), F65–F68 e F71. O limite mensal do Nod é de gasto com modelo, não da fatura do cartão (F57–F59). Dados de uso vêm ligados para novos usuários; registros de conversa vêm desligados (F53–F54).
