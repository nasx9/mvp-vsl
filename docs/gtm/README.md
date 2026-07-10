# Google Tag Manager — Contêiner `GTM-5D9F96N7`

Export do workspace em `GTM-5D9F96N7_workspace25.json` (importável em
*Admin › Import Container*). Este documento resume o contrato entre a página e o
container — o que a landing precisa emitir e o que o GTM faz.

## O que a página emite

A página (`index.html`) empurra **apenas** o evento `form_submit` no
`window.dataLayer`, após o sucesso do webhook e com o formulário ainda
preenchido no DOM:

```js
window.dataLayer.push({ event: 'form_submit', event_id: '<uuid>' });
```

A página **não** dispara `fbq('track','Lead')` nem GA4 diretamente — o GTM é o
dono das conversões (evita contagem dupla).

## O que o GTM faz

### Classificação (Router Lead Classification)

Dispara em `form_submit`. Lê os campos no DOM pelos atributos `name`:

- `voc-dono-do-seu-negcio`
- `qual-o-faturamento-mensal-da-sua-empresa`

Regra: `qualified` quando dono = **"Sim"** e faturamento em
`{21 mil a 50 mil, 51 mil a 100 mil, 101 mil a 500 mil, Acima de 500 mil}`;
caso contrário `unqualified`. Empurra:

```js
{ event: 'form_submit_qualified' | 'form_submit_unqualified',
  lead_type, dono_negocio, faturamento_mensal }
```

> A página mantém esses mesmos `name` de campo. Alterá-los quebra a
> classificação do GTM.

### Conversões (disparadas por form_submit_qualified/unqualified/lead)

| Tag | Destino | Observação |
|---|---|---|
| META \| CORE \| Lead | Meta Pixel `Lead` | `eventID` = template "Unique Event ID" (stape-io) |
| META \| CORE \| Lead_Qualified / Lead_Unqualified | Meta `trackCustom` | segmentação por ICP |
| GA4 \| CORE \| generate_lead (Qualified/Unqualified/Generic) | GA4 `generate_lead` | `G-WQM5FHJF27` |
| GOOGLE ADS \| Conversion \| All Leads | Google Ads `AW-11436681414` | conversão |

O `eventID` do Meta é gerado pelo GTM (browserId + pageLoadId), independente do
`event_id` que a página envia ao n8n. Dedup browser↔CAPI, se necessária, deve
ser tratada no n8n conforme a estratégia de Meta CAPI do time.

### Redirect para página de obrigado — DESABILITADO pela página

As tags `HTML | CORE | Redirect Qualified` e `Redirect Unqualified` redirecionam
o lead (após 1200ms) para uma página de obrigado, mas checam:

```js
if (window.__redirect_done) return;
```

A página seta `window.__redirect_done = true` no submit (via
`CONFIG.redirectToThankYou`, padrão `false`), **cancelando** esse redirect para
ICP e S_ICP. O fluxo ativo é o próprio do VSL: painel de sucesso + contagem
regressiva para o WhatsApp.

Para reativar o redirect do GTM: `CONFIG.redirectToThankYou = true` no
`index.html` (e desabilite o redirecionamento ao WhatsApp para não conflitar).

## IDs de referência (públicos, client-side)

- Container GTM: `GTM-5D9F96N7`
- GA4: `G-WQM5FHJF27`
- Google Ads: `AW-11436681414`
