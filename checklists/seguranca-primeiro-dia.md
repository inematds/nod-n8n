# Checklist — segurança no primeiro dia

Recomendações do kit, ancoradas nas regras documentadas. Veja fontes e ressalvas em [FATOS.md](../FATOS.md).

- [ ] Desligue **Share usage data** em **Settings → Privacy & data** se não quiser novos envios. O padrão para novos usuários é ligado; isso não apaga dados já enviados. (F53)
- [ ] Mantenha **Share conversation traces** desligado no começo. É outro controle; pseudonimização não garante anonimato. (F54)
- [ ] Se usar API model, defina o limite em **Usage**. Confira o que conta e não conta; não trate a estimativa como fatura final. Trabalho em curso pode terminar depois do limite. Esse limite é de gasto com o modelo, não da fatura do cartão; o kit sugere cartão virtual ou limite baixo configurado no banco. (F57–F59)
- [ ] Escolha modelo e trust checker conscientemente. Mesmo rodando no servidor, o julgamento é de modelo. (F22–F23, F34, F52)
- [ ] Conecte apenas o app necessário, leia o consentimento e confira a conta. Adie contas extras e permissões amplas de ação automática. ZDR não reduz a permissão OAuth. (F24–F27, F35)
- [ ] Adie cartões e **Include sensitive details** enquanto você avalia o uso. Não importe todos os logins como primeiro passo. Essa é uma escolha conservadora do kit, não uma exigência do Nod. (F31–F32, F45)
- [ ] Use Vault e formulários privados para senhas e códigos. Não coloque segredos na conversa. No pagamento, confira loja, valor e moeda; o código é pedido a cada vez e nunca salvo. (F31–F33)
- [ ] Acrescente “peça minha aprovação antes de enviar, excluir, comprar ou cancelar” nos pedidos em que você quer revisão. O seu pedido explícito já pode dar autoridade; não conte com pergunta automática em todo caso. (F35)
- [ ] Confira **Settings → Notifications** antes de ativar preparação automática. A doc diverge sobre o estado inicial. Revise schedules, instruções e fuso em vez de presumir automação ativa. (F60–F62)
- [ ] Revise **Settings → Memory**, inclusive **Skills** e **Let go**. Notas e skills não são autorização para agir. (F44–F48)
- [ ] Se usar canais, faça login e pagamento no Nod web/desktop. No WhatsApp QR, leia o risco do cliente não oficial antes de conectar. (F28–F30)
- [ ] No servidor, proteja o token e use túnel SSH ou HTTPS. Guarde backup com a Vault key e não exponha os serviços internos. (F10, F14–F18)
- [ ] Ao final da primeira tarefa, confira **Usage**. Se o resultado de uma ação for incerto, confira o estado antes de repetir. (F33, F39–F40)
- [ ] Revise diagnóstico e screenshot antes de enviar feedback. (F55)
