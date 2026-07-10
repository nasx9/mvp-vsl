# syntax=docker/dockerfile:1

# Imagem única de runtime. A página é estática (HTML/CSS/JS autocontido),
# portanto não há etapa de build de assets nem runtime Node.js.
# Base fixada conforme AGENTS.md (regra funcional obrigatória).
FROM nginx:1.27-alpine

# Configuração de servidor: rotas, cache, gzip, headers e healthcheck.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia explícita do único artefato servido (previsível, sem globs).
COPY index.html /usr/share/nginx/html/index.html

# O master do nginx precisa de root para bind na porta 80; os workers
# já rodam como usuário não privilegiado `nginx` (definido na imagem base).
EXPOSE 80

# Healthcheck real de aplicação: valida a resposta HTTP do endpoint /health,
# não apenas a existência do processo.
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1/health || exit 1
