# Checklist — Pré-Deploy

## Build e aplicação

- [ ] `docker build` conclui sem erro.
- [ ] `scripts/smoke.sh` (ou `mise run smoke`) passa 100%.
- [ ] Nenhum segredo/token no `index.html` ou no repositório.

## Front-end

- [ ] Responsividade validada (320 px até desktop).
- [ ] Sem erros relevantes no console.
- [ ] Meta tags e Open Graph revisados.
- [ ] Player VTurb carrega.
- [ ] Eventos de conversão testados (`generate_lead` após sucesso do webhook).

## Fluxo crítico

- [ ] VTurb revela `#form` no pitch sem abrir o modal.
- [ ] Modal abre no clique; fecha por botão, backdrop e `Escape`.
- [ ] Validação e normalização de WhatsApp funcionam.
- [ ] JSON enviado ao webhook confere com o contrato do n8n.

## Integrações

- [ ] Webhook do n8n de produção respondendo (200/201).
- [ ] CORS e resposta HTTP do webhook confirmados.
- [ ] UTMs e IDs de anúncio capturados.
- [ ] GTM e Pixel configurados, quando aplicável.

## Infraestrutura e segurança

- [ ] DNS apontado para o Coolify.
- [ ] HTTPS ativo e redirecionamento HTTP→HTTPS.
- [ ] Porta 80 configurada no recurso do Coolify.
- [ ] Healthcheck `/health` disponível.
- [ ] Plano de rollback definido (redeploy do commit anterior).
