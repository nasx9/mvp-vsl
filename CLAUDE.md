@AGENTS.md

## Claude Code

- Use `AGENTS.md` como fonte primária de regras deste projeto.
- Antes de implementar, confirme escopo e critérios de aceite. Faça um plano
  curto e execute uma mudança por vez.

## Regras críticas deste projeto

Não altere sem solicitação explícita (impacto externo no VTurb / n8n / mídia):

- ID do player VTurb `6a5012373c43e1aa78fc1dae`.
- ID `form` revelado pelo recurso "Mostrar conteúdo oculto".
- URL do webhook do n8n.
- Nomes dos campos do formulário e estrutura do payload.
- Nome do evento de conversão `generate_lead` e campos de tracking.

## Stack e ambiente

- HTML5 + CSS puro + JavaScript puro. Sem React, Vue, jQuery, Tailwind ou
  bundlers. Sem runtime Node.js em produção.
- Docker-first: a imagem `nginx:1.27-alpine` é a referência de runtime.
- Valide toda mudança com `mise run smoke` (ou `scripts/smoke.sh`) e teste local
  por HTTP, nunca só por `file://`.

## Memória e contexto externo

- Não carregue vault Obsidian inteiro. Use apenas contexto curado de
  `ai-context` ou arquivos explicitamente indicados.
- Não leia nem registre secrets, tokens, `.env` ou dados sensíveis de clientes.
