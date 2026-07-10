# Visão Geral

## O que é

Landing page da **Aula do Método Flywheel** — uma VSL (Video Sales Letter).
Página estática de arquivo único que exibe o player de vídeo do VTurb e, no
momento do pitch, revela um CTA. Ao clicar, o usuário preenche um formulário em
modal que gera um lead via webhook do n8n.

## Objetivo

Capturar leads qualificados a partir do tráfego pago (Meta/Google/TikTok),
preservando atribuição de mídia (UTMs e IDs de anúncio) e disparando o evento de
conversão `generate_lead` apenas após confirmação do webhook.

## Fluxo do usuário

1. Usuário acessa a página; o player VTurb carrega o vídeo.
2. No tempo do pitch, o VTurb revela o elemento `#form` ("Mostrar conteúdo
   oculto").
3. Usuário clica em **QUERO FAZER MINHA APLICAÇÃO**.
4. Abre o formulário em modal (sem sair da página).
5. Após validação, os dados são enviados em JSON ao webhook do n8n.
6. A conversão (`generate_lead`) é registrada somente quando o webhook responde
   com sucesso.

## Escopo

- **Incluído:** página estática, player, CTA revelado, modal, formulário,
  validação, normalização de telefone, envio ao webhook, tracking via
  `dataLayer` e Meta Pixel, deploy Docker/Nginx no Coolify.
- **Não incluído:** backend próprio, banco de dados, autenticação, CMS. A
  lógica de negócio (dedupe, CRM, e-mail) vive no fluxo do n8n.

## Maturidade

Nível 1 — Simples (ver `docs/deploy/` e o padrão dev-stack). Build automatizado
no CI, deploy manual controlado no Coolify, rollback pela versão anterior.

## Restrições

- Sem frameworks front-end nem bundlers (ver `AGENTS.md`).
- Sem segredos no frontend; o webhook é público e deve ser protegido no n8n.
- Contrato de payload e nomes de eventos são fixos e coordenados com o n8n.
