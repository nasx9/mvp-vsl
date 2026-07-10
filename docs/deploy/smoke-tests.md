# Smoke Tests

Validação rápida de que a versão publicada funciona nos fluxos críticos de uma
landing page de captação.

## Automatizados (local / CI)

```bash
scripts/smoke.sh        # ou: mise run smoke
```

Cobre: `/health` = 200, home = 200, presença do player, header
`X-Content-Type-Options`, fallback de rota e healthcheck do container = healthy.

## Manuais (pós-deploy no domínio público)

- [ ] Domínio público responde com **HTTPS** válido.
- [ ] `GET /health` retorna `200 ok`.
- [ ] Home carrega sem erros no console.
- [ ] Player VTurb carrega o vídeo.
- [ ] No tempo do pitch, o CTA (`#form`) é revelado — **sem** abrir o modal.
- [ ] Clique no CTA abre o modal.
- [ ] Modal fecha por botão, backdrop e `Escape`; foco preso e restaurado.
- [ ] Validação de campos obrigatórios funciona.
- [ ] WhatsApp é normalizado (ex.: `5561999999999`).
- [ ] Envio ao webhook do n8n responde com sucesso.
- [ ] Evento `generate_lead` dispara **somente** após o sucesso do webhook.
- [ ] UTMs e IDs de anúncio chegam ao n8n.
- [ ] Testado em largura de 320 px e em desktop.

## Registro esperado

Ao final, registre: versão/commit testado, ambiente, data/hora, testes
executados, resultado e decisão (manter, corrigir para frente ou rollback).
