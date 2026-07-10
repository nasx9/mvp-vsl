# Arquitetura Geral

## Visão de componentes

```text
Navegador do usuário
  │
  ├─ index.html (HTML + CSS + JS autocontido)
  │    ├─ Player VTurb (script externo converteai.net)
  │    ├─ CTA revelado pelo VTurb (#form)
  │    ├─ Modal + formulário de lead
  │    └─ Tracking: dataLayer (GTM) + Meta Pixel (fbq)
  │
  ├─ POST JSON ──▶ Webhook n8n (n8n.catapultadigital.com.br)
  │                   └─ normaliza, dedupe, CRM, notificações
  │
  └─ Servido por ──▶ Nginx (container Docker) ──▶ Coolify (VPS)
```

## Camadas

| Camada | Responsabilidade | Tecnologia |
|---|---|---|
| Apresentação | Player, CTA, modal, formulário, estilos | HTML5 + CSS puro |
| Comportamento | Validação, máscara/normalização, tracking, envio | JavaScript puro |
| Entrega | Servir estático, cache, headers, healthcheck | Nginx `1.27-alpine` |
| Empacotamento | Imagem previsível de produção | Docker |
| Orquestração | Deploy, domínio, HTTPS | Coolify |
| Integração | Recebe o lead e executa a automação | Webhook n8n |

## Decisões-chave

- **Arquivo único autocontido:** simplifica o deploy e elimina dependências de
  build. Ver ADR-0001.
- **Sem backend:** a página só emite um POST; toda regra de negócio fica no n8n.
- **Conversão confiável:** `generate_lead` só dispara após resposta HTTP de
  sucesso do webhook, evitando falso positivo de conversão.
- **`event_id` único por lead:** permite futura deduplicação entre Meta Pixel
  (browser) e Conversions API (server).

## Contrato com o n8n

O payload preserva os grupos `event`, `page_title`, `event_id`, `event_time`,
`lead`, `tracking` e `metadata`. Os nomes dos campos são fixos; qualquer
mudança de contrato precisa ser coordenada com o fluxo do n8n e documentada
(ver `AGENTS.md` › "Alterações que exigem atenção especial"). O payload completo
está descrito no `README.md`.

## Rastreamento

Eventos enviados ao `dataLayer` (quando GTM disponível):
`vsl_pitch_reached`, `vsl_cta_revealed`, `vsl_cta_clicked`, `vsl_form_opened`,
`vsl_form_started`, `vsl_form_validation_error`, `vsl_form_submit`,
`generate_lead`, `vsl_form_submit_error`. O evento `Lead` também é enviado ao
Meta Pixel (quando `fbq` disponível) com o mesmo `event_id`.
