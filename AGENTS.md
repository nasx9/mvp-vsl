# AGENTS.md

## Objetivo do projeto

Este repositório contém uma landing page estática para a **Aula do Método Flywheel**.

A página deve permanecer simples, rápida e independente de frameworks. Ela contém:

- player VTurb;
- CTA revelado pelo recurso Mostrar conteúdo oculto;
- formulário em modal;
- envio para webhook do n8n;
- rastreamento por `dataLayer` e Meta Pixel, quando disponíveis;
- deploy em container Nginx pelo Coolify.

## Stack permitida

Use preferencialmente:

- HTML5 semântico;
- CSS puro;
- JavaScript puro;
- Docker;
- Nginx.

Não introduza React, Vue, Next.js, jQuery, Bootstrap, Tailwind ou bundlers sem solicitação explícita.

## Arquivos principais

```text
index.html   Página, estilos e scripts da VSL
Dockerfile   Imagem Nginx para produção
nginx.conf   Rotas, cache e healthcheck
README.md    Documentação operacional
AGENTS.md    Regras para manutenção por agentes
```

Enquanto o arquivo ainda se chamar `insidesale-vsl.html`, trate-o como a origem do futuro `index.html`.

## Regras funcionais obrigatórias

### Player VTurb

Preserve o player e seu identificador:

```text
6a5012373c43e1aa78fc1dae
```

Não substitua o embed JavaScript por iframe sem necessidade comprovada.

### Conteúdo oculto

O VTurb revela o elemento:

```html
<div id="form" class="vturb-hidden-content" style="display: none;">
```

No painel do VTurb, o seletor esperado é:

```text
Tipo: ID
Valor: form
```

Não renomeie o ID `form` sem atualizar também a configuração no VTurb.

O VTurb deve apenas revelar o CTA. O modal não deve abrir automaticamente. O usuário precisa clicar no botão revelado.

### Modal

O modal deve:

- abrir somente após o clique no CTA;
- fechar pelo botão de fechar;
- fechar ao clicar no backdrop;
- fechar com `Escape`;
- manter focus trap pelo teclado;
- bloquear o scroll do documento enquanto estiver aberto;
- funcionar em desktop e celular;
- preservar atributos ARIA.

Não adicione headline, parágrafos promocionais ou textos auxiliares dentro do modal sem solicitação explícita. O modal deve conter somente o formulário, seus feedbacks essenciais e o controle de fechamento.

### Formulário

Preserve os campos:

- `nome`;
- `e-mail`;
- `ddd-whatsapp`;
- `voc-dono-do-seu-negcio`;
- `segmento-da-empresa`;
- `qual-o-faturamento-mensal-da-sua-empresa`;
- `polticas-de-privacidade`.

Preserve o honeypot `website`.

Campos obrigatórios devem continuar usando validação nativa e feedback visual acessível.

O telefone deve ser normalizado para o padrão brasileiro antes do envio, preferencialmente como:

```text
5561999999999
```

### Webhook

Webhook de produção atual:

```text
https://n8n.catapultadigital.com.br/webhook/637a9f9a-4f87-4e80-861a-6488d1ed4885
```

Não altere essa URL sem solicitação explícita.

O envio deve permanecer em JSON via `fetch` usando `POST`.

A conversão só pode ser considerada concluída após uma resposta HTTP bem-sucedida do webhook.

Não envie credenciais privadas, tokens ou segredos no frontend.

### Payload

Preserve os grupos principais:

```text
event
page_title
event_id
event_time
lead
tracking
metadata
```

Preserve os nomes dos campos existentes para evitar quebra do workflow no n8n.

Qualquer mudança de contrato precisa ser documentada no README e coordenada com o fluxo do n8n.

### Rastreamento

Preserve, quando aplicável, os eventos:

```text
vsl_pitch_reached
vsl_cta_revealed
vsl_cta_clicked
vsl_form_opened
vsl_form_started
vsl_form_validation_error
vsl_form_submit
generate_lead
vsl_form_submit_error
```

`generate_lead` deve ocorrer apenas depois do sucesso do webhook.

Preserve o `event_id` para futura deduplicação entre browser Pixel e Meta Conversions API.

Preserve a captura dos parâmetros:

```text
utm_source
utm_medium
utm_campaign
utm_content
utm_term
ad_id
adset_id
campaign_id
fbclid
gclid
ttclid
```

## Regras de design

- A página deve exibir somente o player e, após o pitch, o CTA.
- Não adicionar cabeçalho, rodapé, headline ou blocos promocionais sem solicitação.
- Manter o fundo escuro.
- Manter o CTA com alta visibilidade e boa área de toque.
- Garantir largura mínima suportada de 320 px.
- Evitar dependências externas desnecessárias.
- Não especificar mudanças visuais que prejudiquem o carregamento do player.

## Acessibilidade

Toda alteração deve preservar ou melhorar:

- navegação por teclado;
- foco visível;
- labels acessíveis;
- `aria-modal`;
- `aria-hidden`;
- foco inicial no modal;
- retorno de foco ao elemento que abriu o modal;
- mensagens de erro e sucesso legíveis por tecnologias assistivas.

## Performance

- Não bloquear o carregamento do player.
- Scripts não críticos devem permanecer assíncronos ou no fim do documento.
- Evitar imagens, fontes e bibliotecas desnecessárias.
- Não adicionar múltiplos listeners globais quando delegação de eventos resolver.
- Manter o HTML autocontido enquanto isso simplificar o deploy.

## Docker e Nginx

A imagem deve ser baseada em:

```dockerfile
FROM nginx:1.27-alpine
```

O container deve expor a porta `80`.

O endpoint abaixo deve retornar HTTP 200:

```text
/health
```

Não execute a aplicação como um servidor Node.js, pois não há runtime backend neste projeto.

## Testes mínimos antes de concluir uma alteração

1. Abrir a página por HTTP local, não apenas por `file://`.
2. Confirmar carregamento do player VTurb.
3. Simular a exibição do elemento `#form`.
4. Confirmar que o CTA aparece sem abrir automaticamente o modal.
5. Abrir o modal pelo clique.
6. Fechar por botão, backdrop e `Escape`.
7. Navegar pelo modal usando `Tab` e `Shift + Tab`.
8. Validar campos obrigatórios.
9. Testar máscara e normalização do WhatsApp.
10. Conferir o JSON enviado ao webhook.
11. Confirmar `generate_lead` somente após sucesso.
12. Testar em largura de 320 px e em desktop.
13. Verificar erros no console.
14. Testar o endpoint `/health` no container.

## Convenções de código

- Use `const` e `let`; não use `var` em código novo.
- Prefira funções pequenas com responsabilidade clara.
- Use nomes em inglês para funções e variáveis técnicas, mantendo textos da interface em português.
- Não silencie erros de rede.
- Evite valores mágicos; centralize configurações no objeto `CONFIG`.
- Comente apenas decisões não óbvias.
- Não minifique os arquivos-fonte do repositório.

## Alterações que exigem atenção especial

Antes de modificar qualquer um destes itens, confira o impacto externo:

- ID do player VTurb;
- ID `form`;
- URL do webhook;
- nomes dos campos;
- estrutura do payload;
- nome do evento `generate_lead`;
- campos de tracking;
- domínio e rota pública;
- configuração de CORS no n8n.

## Critério de conclusão

Uma tarefa só está concluída quando:

- a funcionalidade solicitada está implementada;
- não há erro de console relevante;
- o fluxo VTurb → CTA → modal → webhook funciona;
- o contrato com o n8n não foi quebrado;
- o README foi atualizado quando houver mudança operacional;
- a página continua adequada para deploy via Docker/Coolify.

## Padrão de desenvolvimento

Este projeto segue o framework **dev-stack** (`github.com/nasx9/dev-stack`) e o
vault curado **ai-context** (`github.com/nasx9/ai-context`).

- Maturidade: **Nível 1 — Simples** (landing page estática, sem banco crítico).
  Build automatizado no CI e deploy manual controlado no Coolify.
- Ambiente: **Docker-first, mise-for-speed**. O Docker é a fonte de verdade do
  runtime; o `.mise.toml` só padroniza ferramentas locais. Em divergência,
  Docker vence.
- Documentação em português do Brasil, tom técnico e direto.
- Não registrar secrets, tokens, senhas ou dados sensíveis no repositório.

### Estrutura de documentação

```text
docs/
  00-visao-geral.md                     Contexto, objetivo e escopo
  04-arquitetura-geral.md               Componentes e fluxo técnico
  05-ambiente-de-desenvolvimento.md     Runtimes, Docker e execução local
  deploy/coolify.md                     Passo a passo de deploy no Coolify
  deploy/smoke-tests.md                 Validação pós-deploy
  decisoes-tecnicas/adr-0001-*.md       ADR da stack estática + Nginx
  checklists/checklist-pre-deploy.md    Validação antes do deploy
  checklists/checklist-pos-deploy.md    Validação após o deploy
```

### Fluxo para mudanças relevantes

1. Ler `docs/00-visao-geral.md` e `AGENTS.md`.
2. Fazer plano curto antes de alterar arquivos.
3. Executar uma mudança por vez, pequena e verificável.
4. Validar com `scripts/smoke.sh` (ou `mise run smoke`) e teste local por HTTP.
5. Atualizar documentação afetada e registrar ADR em decisão técnica relevante.
6. Informar arquivos alterados, validações executadas e riscos restantes.

### Entrega esperada

- Arquivos criados ou alterados.
- Validações executadas (build, smoke tests, teste manual do fluxo).
- Riscos restantes e próximo passo recomendado.
