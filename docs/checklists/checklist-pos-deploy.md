# Checklist — Pós-Deploy

## Disponibilidade

- [ ] Domínio público responde com HTTPS válido.
- [ ] `GET /health` retorna `200 ok`.
- [ ] Home carrega e o player VTurb aparece.
- [ ] Certificado SSL válido e sem avisos de conteúdo misto.

## Fluxo de conversão (teste real)

- [ ] CTA revela no tempo do pitch.
- [ ] Modal abre, valida e envia.
- [ ] Lead de teste chega ao n8n com UTMs e IDs.
- [ ] `generate_lead` disparado apenas após sucesso do webhook.
- [ ] Evento `Lead` no Meta Pixel (se Pixel ativo) com o mesmo `event_id`.

## Observabilidade e operação

- [ ] Logs do container sem erros relevantes (via Coolify).
- [ ] Healthcheck do container = `healthy`.
- [ ] Versão/commit implantado registrado.

## Registro do deploy

Anote: commit implantado, data/hora, responsável, resultado dos smoke tests e
decisão final (manter / corrigir para frente / rollback).
