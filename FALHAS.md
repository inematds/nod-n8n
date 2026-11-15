# Changelog de falhas

| data | o que quebrou | menor correção | prompt ou infra |
| --- | --- | --- | --- |
| 2026-11-15 | Checagem HTTP deu 403 com Nod saudável porque usou Host 127.0.0.1 | Enviar Host localhost:PORT, igual à origem configurada; documentar o acesso pelo navegador | prompt |
| 2026-11-15 | Primeira inicialização falhou: Compose expandiu NOD_PUBLIC_URL sem porta porque PORT foi movido ao fim do .env | Escrever PORT antes das variáveis que o referenciam e validar origin efetiva | prompt |
| 2026-11-15 | Pré-checagem da VPS encontrou Docker sem Buildx | Instalar só docker-buildx, sem reiniciar Docker; exigir plugin no script | infra |
| 2026-11-15 | Teste e textos tratavam Compose 5.2.0 como fora do requisito v2; guia omitia distinções da fonte | Aceitar major ≥ 2 no teste e alinhar aprovação, comparação e instalação à documentação clonada | prompt |
| 2026-11-15 | Gerador temporário do HTML não compilou por fechamento incorreto de lista | Fechar a lista da compreensão antes da chamada grid | infra |
