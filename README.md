# Aula do Método Flywheel — VSL

Landing page estática da **Aula do Método Flywheel**, construída com HTML, CSS e JavaScript puro para publicação via Docker/Nginx no Coolify.

A página apresenta o player do VTurb e, no momento configurado do pitch, revela um botão abaixo do vídeo. Ao clicar, o usuário abre um formulário em modal sem sair da página.

## Fluxo da página

1. O usuário acessa a página da VSL.
2. O player do VTurb carrega o vídeo.
3. No tempo do pitch, o VTurb usa **Mostrar conteúdo oculto** para exibir o elemento com `id="form"`.
4. O usuário clica em **QUERO FAZER MINHA APLICAÇÃO**.
5. O formulário é aberto em modal.
6. Após a validação, os dados são enviados em JSON ao webhook do n8n.
7. A conversão é registrada somente quando o webhook responde com sucesso.

## Tecnologias

- HTML5
- CSS3
- JavaScript puro
- VTurb SmartPlayer
- Webhook n8n
- Google Tag Manager, opcional
- Meta Pixel, opcional
- Docker
- Nginx
- Coolify

## Estrutura recomendada

```text
.
├── index.html
├── Dockerfile
├── nginx.conf
├── README.md
└── AGENTS.md
```

O arquivo atual pode ser renomeado de `insidesale-vsl.html` para `index.html` antes do deploy.

## Configuração do VTurb

No painel do VTurb, configure o elemento de ação no momento do pitch:

```text
Ação: Mostrar conteúdo oculto
Tipo de seletor: ID
Valor: form
```

Use somente `form`, sem `#`.

O elemento controlado pelo VTurb é:

```html
<div id="form" class="vturb-hidden-content" style="display: none;">
  <button id="open-form-modal" type="button">
    QUERO FAZER MINHA APLICAÇÃO
  </button>
</div>
```

O VTurb torna esse contêiner visível. O modal só é aberto depois do clique do usuário.

## Webhook

O formulário envia os dados para:

```text
https://n8n.catapultadigital.com.br/webhook/637a9f9a-4f87-4e80-861a-6488d1ed4885
```

A URL está definida no objeto `CONFIG` do JavaScript:

```javascript
const CONFIG = {
  webhookUrl: 'https://n8n.catapultadigital.com.br/webhook/637a9f9a-4f87-4e80-861a-6488d1ed4885',
  pageTitle: 'Aula do Método Flywheel',
  videoId: '6a5012373c43e1aa78fc1dae',
  funnel: 'vsl-inside-sales'
};
```

O webhook deve aceitar `POST` com `Content-Type: application/json` e responder com HTTP `200` ou `201`.

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

- Nome
- E-mail
- DDD + WhatsApp
- É dono do negócio?
- Segmento da empresa
- Faturamento mensal
- Consentimento LGPD

Também existem campos ocultos para rastreamento de mídia e atribuição.

## Eventos de rastreamento

A página envia eventos para `window.dataLayer` quando disponível:

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

O evento principal de conversão é:

```text
generate_lead
```

Ele só é disparado após o webhook responder com sucesso.

Se `window.fbq` estiver disponível, a página também envia o evento `Lead` para o Meta Pixel usando o mesmo `event_id`, permitindo deduplicação futura com a Conversions API.

## Google Tag Manager

O código do GTM está comentado no `<head>` e no início do `<body>`.

Substitua:

```text
GTM-XXXXXXX
```

pelo ID real do contêiner e remova os comentários dos dois blocos.

## Execução local

Por ser uma página estática, não abra apenas com `file://` para testar integrações. Utilize um servidor HTTP local.

Com Python:

```bash
python3 -m http.server 8080
```

Com Node.js:

```bash
npx serve .
```

Acesse:

```text
http://localhost:8080
```

## Docker

Exemplo de `Dockerfile`:

```dockerfile
FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1/health || exit 1
```

Exemplo de `nginx.conf`:

```nginx
server {
    listen 80;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location = /health {
        access_log off;
        add_header Content-Type text/plain;
        return 200 "ok\n";
    }

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(?:css|js|jpg|jpeg|png|gif|svg|webp|ico|woff2?)$ {
        expires 7d;
        add_header Cache-Control "public, max-age=604800, immutable";
        try_files $uri =404;
    }
}
```

## Deploy no Coolify

1. Envie o repositório para GitHub, GitLab ou outro provedor Git suportado.
2. No Coolify, crie um novo recurso a partir do repositório.
3. Escolha o build por `Dockerfile`.
4. Configure a porta exposta como `80`.
5. Cadastre o domínio da página.
6. Ative HTTPS.
7. Faça o deploy.
8. Verifique o healthcheck em `/health`.

Caso a URL pública precise permanecer como `/insidesale`, há duas possibilidades:

- apontar um domínio ou subdomínio diretamente para esta aplicação; ou
- manter o proxy principal encaminhando `/insidesale` para este container.

## Checklist de produção

- [ ] Renomear o HTML principal para `index.html`.
- [ ] Validar o webhook de produção do n8n.
- [ ] Confirmar CORS e resposta HTTP do webhook.
- [ ] Configurar `form` no recurso Mostrar conteúdo oculto do VTurb.
- [ ] Testar a revelação do CTA no tempo correto.
- [ ] Testar abertura e fechamento do modal.
- [ ] Testar validações em desktop e celular.
- [ ] Confirmar captura de UTMs e IDs de anúncios.
- [ ] Configurar GTM e Pixel, quando aplicável.
- [ ] Confirmar o evento `generate_lead` após sucesso.
- [ ] Ativar HTTPS no Coolify.
- [ ] Validar `/health`.

## Segurança

- Não coloque tokens, chaves privadas ou credenciais no HTML.
- O webhook fica visível no frontend; portanto, o fluxo do n8n deve validar o payload, aplicar rate limit e usar proteção contra spam.
- Não confie apenas na validação do navegador. Faça validação e normalização novamente no n8n.
- Preserve o honeypot existente no formulário.
- Para integrações sensíveis, encaminhe a solicitação por uma API intermediária em vez de expor credenciais no cliente.

## Licença

Projeto privado da IF Development. Uso e distribuição restritos aos responsáveis pelo projeto.
