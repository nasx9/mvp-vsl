# Aula do Método Flywheel — VSL

Landing page estática da **Aula do Método Flywheel**, construída com HTML, CSS e
JavaScript puro para publicação via Docker/Nginx no Coolify.

A página apresenta o player do VTurb e, no momento configurado do pitch, revela
um botão abaixo do vídeo. Ao clicar, o usuário abre um formulário em modal sem
sair da página. O lead é enviado ao webhook do n8n e a conversão só é registrada
após resposta de sucesso.

## Padrão de desenvolvimento

Projeto alinhado ao framework [dev-stack](https://github.com/nasx9/dev-stack) e
ao vault [ai-context](https://github.com/nasx9/ai-context). Maturidade
**Nível 1 — Simples**: build automatizado no CI, deploy manual controlado no
Coolify, rollback pela versão anterior. Regras para agentes em `AGENTS.md` /
`CLAUDE.md`.

## Estrutura

```text
.
├── index.html            Página, estilos e scripts da VSL (autocontido)
├── Dockerfile            Imagem Nginx de produção
├── nginx.conf            Rotas, cache, headers de segurança e healthcheck
├── .dockerignore         Contexto de build mínimo
├── .mise.toml            Ferramentas locais e tasks (serve/build/smoke)
├── scripts/smoke.sh      Smoke tests automatizados
├── AGENTS.md             Regras de manutenção por agentes
├── CLAUDE.md             Ponte de instruções para o Claude Code
├── .github/workflows/    CI: build da imagem + smoke tests
└── docs/                 Visão, arquitetura, ambiente, deploy, ADRs, checklists
```

Comece por `docs/00-visao-geral.md`.

## Fluxo da página

1. O usuário acessa a página da VSL.
2. O player do VTurb carrega o vídeo.
3. No tempo do pitch, o VTurb usa **Mostrar conteúdo oculto** para exibir o
   elemento com `id="form"`.
4. O usuário clica em **QUERO FAZER MINHA APLICAÇÃO**.
5. O formulário é aberto em modal.
6. Após a validação, os dados são enviados em JSON ao webhook do n8n.
7. A conversão é registrada somente quando o webhook responde com sucesso.

## Tecnologias

HTML5 · CSS3 · JavaScript puro · VTurb SmartPlayer · Webhook n8n · Google Tag
Manager (opcional) · Meta Pixel (opcional) · Docker · Nginx · Coolify.

## Execução local

Por ser uma página estática, não abra apenas com `file://`. Use um servidor HTTP:

```bash
mise run serve                 # http://localhost:8080
# ou:
python3 -m http.server 8080
npx --yes serve -l 8080 .
```

Rodar como em produção e validar com smoke tests:

```bash
mise run build                 # docker build -t mvp-vsl:local .
mise run smoke                 # build + container + testes de fumaça
```

Detalhes em `docs/05-ambiente-de-desenvolvimento.md`.

## Configuração do VTurb

No painel do VTurb, configure o elemento de ação no momento do pitch:

```text
Ação: Mostrar conteúdo oculto
Tipo de seletor: ID
Valor: form
```

Use somente `form`, sem `#`. O elemento controlado pelo VTurb é:

```html
<div id="form" class="vturb-hidden-content" style="display: none;">
  <button id="open-form-modal" type="button">
    QUERO FAZER MINHA APLICAÇÃO
  </button>
</div>
```

O VTurb apenas torna o contêiner visível. O modal só abre após o clique do
usuário.

## Webhook

O formulário envia os dados para:

```text
https://n8n.catapultadigital.com.br/webhook/637a9f9a-4f87-4e80-861a-6488d1ed4885
```

A URL está definida no objeto `CONFIG` do JavaScript no `index.html`. O webhook
deve aceitar `POST` com `Content-Type: application/json` e responder com HTTP
`200` ou `201`.

### Payload principal

```json
{
  "event": "vsl_lead_generated",
  "page_title": "Aula do Método Flywheel",
  "event_id": "uuid-do-evento",
  "event_time": 1783699200,
  "lead": {
    "name": "Nome do lead",
    "email": "lead@empresa.com.br",
    "phone": "5561999999999",
    "is_business_owner": "Sim",
    "company_segment": "Tecnologia",
    "monthly_revenue": "101 mil a 500 mil",
    "privacy_consent": true
  },
  "tracking": {
    "utm_source": "meta",
    "utm_medium": "paid-social",
    "utm_campaign": "campanha",
    "utm_content": "criativo",
    "utm_term": "publico",
    "ad_id": "123",
    "adset_id": "456",
    "campaign_id": "789",
    "fbclid": "...",
    "gclid": "...",
    "ttclid": "...",
    "landing_page": "https://dominio.com/insidesale",
    "page_path": "/insidesale",
    "referrer": null,
    "video_id": "6a5012373c43e1aa78fc1dae",
    "funnel": "vsl-inside-sales"
  }
}
```

## Campos do formulário

Nome · E-mail · DDD + WhatsApp · É dono do negócio? · Segmento da empresa ·
Faturamento mensal · Consentimento LGPD. Há também campos ocultos de
rastreamento e um honeypot (`website`).

## Sucesso e redirecionamento ao WhatsApp

Após o webhook responder com sucesso, o formulário é substituído por um painel de
sucesso dentro do modal, com mensagem informando que um especialista entrará em
contato. Uma contagem regressiva redireciona automaticamente o usuário para o
WhatsApp; há também um botão para ir imediatamente.

Configurável no objeto `CONFIG` do `index.html`:

```javascript
whatsappUrl: 'https://wa.me/5561992194586',
redirectDelaySeconds: 5
```

O clique manual no botão cancela a contagem para evitar navegação duplicada.

## Eventos de rastreamento

Enviados a `window.dataLayer` quando disponível:

```text
vsl_pitch_reached · vsl_cta_revealed · vsl_cta_clicked · vsl_form_opened
vsl_form_started · vsl_form_validation_error · vsl_form_submit
generate_lead · vsl_form_submit_error
```

O evento de conversão `generate_lead` só é disparado após o webhook responder
com sucesso. Se `window.fbq` estiver disponível, o evento `Lead` também é enviado
ao Meta Pixel com o mesmo `event_id` (deduplicação futura com a Conversions API).

## Google Tag Manager

O código do GTM está comentado no `<head>`. Substitua `GTM-XXXXXXX` pelo ID real
do contêiner e remova os comentários.

## Docker

```bash
docker build -t mvp-vsl:local .
docker run -d -p 8080:80 mvp-vsl:local
# valide: http://localhost:8080  e  http://localhost:8080/health
```

A imagem usa `nginx:1.27-alpine`, expõe a porta `80` e define um healthcheck em
`/health`. A configuração de rotas, cache e headers está em `nginx.conf`.

## Deploy no Coolify

Passo a passo completo em `docs/deploy/coolify.md`. Resumo:

1. Crie um recurso *Application* a partir do repositório Git, branch `main`.
2. Build por `Dockerfile`, porta exposta `80`.
3. Cadastre o domínio e ative HTTPS.
4. Configure o health check em `/health` e faça o deploy.
5. Rode os smoke tests de `docs/deploy/smoke-tests.md` contra o domínio público.

Rollback: *Redeploy* do commit anterior no Coolify (sem estado, imediato).

## Checklists

- Antes do deploy: `docs/checklists/checklist-pre-deploy.md`
- Depois do deploy: `docs/checklists/checklist-pos-deploy.md`

## Segurança

- Não coloque tokens, chaves privadas ou credenciais no HTML.
- O webhook fica visível no frontend; o fluxo do n8n deve validar o payload,
  aplicar rate limit e proteção contra spam.
- Não confie apenas na validação do navegador; revalide e normalize no n8n.
- Preserve o honeypot `website` do formulário.
- Para integrações sensíveis, use uma API intermediária em vez de expor
  credenciais no cliente.

## Licença

Projeto privado da IF Development. Uso e distribuição restritos aos responsáveis
pelo projeto.
