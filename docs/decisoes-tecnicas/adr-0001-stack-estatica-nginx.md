# ADR-0001 — Stack estática servida por Nginx em container

- **Status:** Aceita
- **Data:** 2026-07-10
- **Contexto do projeto:** VSL de captação de leads (Nível 1 — Simples)

## Contexto

Precisamos publicar uma landing page de VSL que exibe um player VTurb, revela um
CTA no pitch e envia leads a um webhook do n8n. Não há necessidade de backend,
banco de dados, autenticação ou renderização dinâmica. O deploy será feito no
Coolify sobre uma VPS.

## Decisão

- **Front-end:** HTML5 + CSS puro + JavaScript puro, em um único arquivo
  `index.html` autocontido. Sem React/Vue/bundlers.
- **Runtime:** Nginx `1.27-alpine` em container Docker, servindo o estático.
- **Deploy:** Coolify com build por `Dockerfile`, porta 80, HTTPS e healthcheck
  em `/health`.
- **Configuração:** valores de negócio (webhook, IDs) permanecem no `CONFIG` do
  `index.html`, hardcoded, por decisão de escopo.

## Alternativas consideradas

| Alternativa | Por que não |
|---|---|
| React + Vite + Tailwind | Overhead de build e dependências para uma página única; sem ganho real. |
| Cloudflare Pages / hosting estático | Válido, mas o padrão do time é Docker/Coolify na VPS própria. |
| Backend próprio (Node/PHP) | Sem regra de negócio local; a automação vive no n8n. |
| Variáveis de ambiente para config | Adiciona substituição em build; escopo optou por manter hardcoded. |

## Modelo de privilégio do container

A imagem base `nginx:1.27-alpine` é mandatória (AGENTS.md) e o container expõe a
porta 80. O processo master do Nginx roda como root apenas para o bind na porta
80; os workers já rodam como usuário não privilegiado `nginx`. Não adotamos
execução totalmente rootless para preservar a base e a porta exigidas — trade-off
aceitável para Nível 1. Reavaliar se a criticidade aumentar.

## Consequências

- **Positivas:** deploy simples e previsível, imagem pequena, rollback trivial
  (sem estado), superfície de ataque mínima.
- **Negativas:** configuração exige mudança de código + rebuild; sem SSR/SEO
  dinâmico (irrelevante para o caso); regra de negócio depende do n8n estar no ar.
