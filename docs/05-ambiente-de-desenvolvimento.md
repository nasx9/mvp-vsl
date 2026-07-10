# Ambiente de Desenvolvimento

## Política

**Docker-first, mise-for-speed.** O Docker define o ambiente reproduzível de
produção e é a fonte de verdade. O `mise` apenas padroniza ferramentas locais de
conveniência. Em caso de divergência, o comportamento do Docker prevalece.

## Runtimes

Declarados em `.mise.toml`:

| Ferramenta | Versão | Uso |
|---|---|---|
| Node.js | 24 | Apenas tooling local (ex.: `serve` para HTTP local) |
| Nginx | 1.27-alpine | Runtime de produção (via Docker) |

Não há runtime Node.js em produção — a página é 100% estática.

## Setup local

```bash
mise install        # instala as ferramentas declaradas (opcional)
```

## Executar localmente

Não abra a página por `file://` (quebra integrações). Use um servidor HTTP:

```bash
mise run serve                 # http://localhost:8080  (usa npx serve)
# ou, sem mise:
python3 -m http.server 8080
npx --yes serve -l 8080 .
```

## Rodar como em produção (Docker)

```bash
mise run build                 # docker build -t mvp-vsl:local .
docker run -d -p 8080:80 mvp-vsl:local
# valide: http://localhost:8080  e  http://localhost:8080/health
```

## Smoke tests

```bash
mise run smoke                 # build + container + testes de fumaça
# ou:
scripts/smoke.sh
```

O script valida `/health`, a home, os headers de segurança, o fallback de rota e
o healthcheck do container.

## Convenções de código

- `const`/`let`, nunca `var` em código novo.
- Funções pequenas e nomeadas em inglês; textos de UI em português.
- Configurações centralizadas no objeto `CONFIG` do `index.html`.
- Não silenciar erros de rede. Não minificar os arquivos-fonte.
