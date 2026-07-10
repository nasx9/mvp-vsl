# Deploy no Coolify

Guia operacional para publicar a VSL no Coolify. Maturidade Nível 1: build
automatizado no CI, deploy manual controlado, rollback pela versão anterior.

## Pré-requisitos

- Repositório Git conectado (GitHub `nasx9/mvp-vsl`).
- Servidor/VPS já provisionado no Coolify com Docker e proxy (Traefik) ativos.
- Domínio (ou subdomínio) apontando para o servidor do Coolify.

## Passo a passo

1. **Novo recurso** → *Application* → a partir do repositório Git.
2. **Branch:** `main`.
3. **Build Pack:** `Dockerfile` (o repositório já contém `Dockerfile` e
   `nginx.conf` na raiz).
4. **Porta exposta:** `80`.
5. **Domínio:** cadastre o domínio/subdomínio da página.
6. **HTTPS:** ative o SSL/TLS (Let's Encrypt) e o redirecionamento de HTTP→HTTPS.
7. **Health check:** caminho `/health` (o container também define HEALTHCHECK
   próprio).
8. **Deploy.** Acompanhe o log de build até concluir.

## Rota `/insidesale` (opcional)

Se a URL pública precisar terminar em `/insidesale`:

- aponte um subdomínio dedicado diretamente para esta aplicação; **ou**
- mantenha o proxy principal encaminhando `/insidesale` para este container.

## Versionamento e rollback

- Cada deploy no Coolify fica associado a um commit. Prefira deployar a partir de
  um commit/tag específico, não de um `latest` móvel.
- **Rollback:** no Coolify, faça *Redeploy* do deployment anterior (commit bom
  conhecido). Como não há banco nem migrations, o rollback é imediato e seguro.

## Configuração fixa (sem variáveis de ambiente)

Por decisão do projeto, webhook do n8n e IDs (VTurb, funnel) permanecem no
`index.html` (objeto `CONFIG`). Não há variáveis de ambiente a configurar no
Coolify. Alterar esses valores exige mudança de código coordenada com o n8n
(ver `AGENTS.md`).

## Validação pós-deploy

Rode os smoke tests de `docs/deploy/smoke-tests.md` contra o domínio público.
Mínimo: HTTPS ativo, `/health` = 200, home carrega, player aparece, CTA revela no
pitch, modal abre, formulário envia e `generate_lead` dispara após sucesso.
