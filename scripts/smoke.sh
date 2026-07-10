#!/usr/bin/env bash
# Smoke tests locais: builda a imagem, sobe o container e valida os fluxos
# críticos de uma landing page estática (health, home, headers, healthcheck).
set -euo pipefail

IMAGE="${IMAGE:-mvp-vsl:local}"
NAME="mvp-vsl-smoke"
PORT="${PORT:-8099}"

cleanup() {
  docker rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "==> build da imagem $IMAGE"
docker build -t "$IMAGE" .

cleanup
echo "==> subindo container em :$PORT"
docker run -d --name "$NAME" -p "$PORT:80" "$IMAGE" >/dev/null

# Aguarda o nginx aceitar conexões.
for _ in $(seq 1 20); do
  if curl -fsS -o /dev/null "http://localhost:$PORT/health" 2>/dev/null; then break; fi
  sleep 0.5
done

fail=0

check() {
  local desc="$1"; shift
  if "$@"; then
    echo "  ok  - $desc"
  else
    echo "  FALHA - $desc"
    fail=1
  fi
}

echo "==> smoke tests"
check "/health retorna 200" \
  bash -c "[ \"\$(curl -s -o /dev/null -w '%{http_code}' http://localhost:$PORT/health)\" = 200 ]"
check "/health responde 'ok'" \
  bash -c "curl -s http://localhost:$PORT/health | grep -q ok"
check "/ retorna 200" \
  bash -c "[ \"\$(curl -s -o /dev/null -w '%{http_code}' http://localhost:$PORT/)\" = 200 ]"
check "página contém o player VTurb" \
  bash -c "curl -s http://localhost:$PORT/ | grep -q vturb-smartplayer"
check "header X-Content-Type-Options presente" \
  bash -c "curl -sI http://localhost:$PORT/ | grep -qi 'x-content-type-options: nosniff'"
check "SPA fallback serve index em rota inexistente" \
  bash -c "[ \"\$(curl -s -o /dev/null -w '%{http_code}' http://localhost:$PORT/qualquer-rota)\" = 200 ]"

echo "==> aguardando healthcheck do Docker ficar 'healthy'"
for _ in $(seq 1 30); do
  status="$(docker inspect --format='{{.State.Health.Status}}' "$NAME" 2>/dev/null || echo unknown)"
  [ "$status" = "healthy" ] && break
  sleep 1
done
check "healthcheck do container = healthy" bash -c "[ \"$status\" = healthy ]"

if [ "$fail" -ne 0 ]; then
  echo "==> SMOKE TESTS FALHARAM"
  exit 1
fi
echo "==> SMOKE TESTS OK"
