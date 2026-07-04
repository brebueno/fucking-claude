#!/usr/bin/env bash
# ============================================================================
# fucking-claude — bootstrap
# Reproduz a config semiautônoma (Jarvis) numa máquina nova (macOS/Linux).
# NÃO instala secrets nem dado de cliente. Só o esqueleto de orquestração.
# ============================================================================
set -euo pipefail

CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
say() { printf "\033[0;36m→ %s\033[0m\n" "$1"; }
ok()  { printf "\033[0;32m✓ %s\033[0m\n" "$1"; }
warn(){ printf "\033[0;33m! %s\033[0m\n" "$1"; }

# --- 1. Pré-requisitos -------------------------------------------------------
say "Checando pré-requisitos (node, uv, ripgrep, ffmpeg)"
command -v node >/dev/null || warn "Instale Node 20+ (nvm/brew) antes de continuar"
command -v uv   >/dev/null || { say "Instalando uv"; curl -LsSf https://astral.sh/uv/install.sh | sh; }
if command -v brew >/dev/null; then
  command -v rg     >/dev/null || brew install ripgrep || true
  command -v ffmpeg >/dev/null || brew install ffmpeg  || true
fi

# --- 2. Skill bus (skills.sh) ------------------------------------------------
say "Instalando skills do ecossistema no store universal (~/.agents/skills)"
npx --yes skills add mvanhorn/last30days-skill -g -y            || warn "last30days falhou"
npx --yes skills add rebelytics/one-skill-to-rule-them-all -g -y || warn "task-observer falhou"

# find-skills (vercel-labs, aninhado) — clone + copy
say "Instalando find-skills"
TMP="$(mktemp -d)"; git clone --depth 1 https://github.com/vercel-labs/skills.git "$TMP" >/dev/null 2>&1 || true
mkdir -p "$CLAUDE_DIR/skills"
[ -d "$TMP/skills/find-skills" ] && cp -R "$TMP/skills/find-skills" "$CLAUDE_DIR/skills/find-skills" && ok "find-skills" || warn "find-skills não encontrado"
rm -rf "$TMP"

# --- 3. impeccable (design) --------------------------------------------------
say "Instalando impeccable (design quality)"
( cd "$CLAUDE_DIR/.." && printf 'Y\n' | npx --yes impeccable skills install >/dev/null 2>&1 ) || warn "impeccable: rode 'npx impeccable skills install' manualmente"

# --- 4. Hermes (agente 24/7, runtime à parte) --------------------------------
say "Instalando Hermes agent (sem setup interativo)"
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup --non-interactive || warn "Hermes falhou; veja hermes-agent.nousresearch.com"

# --- 5. OpenWA (gateway WhatsApp) --------------------------------------------
say "Clonando OpenWA (gateway WhatsApp) em ~/agent-stack/OpenWA"
mkdir -p "$HOME/agent-stack"
[ -d "$HOME/agent-stack/OpenWA/.git" ] || git clone --depth 1 https://github.com/rmyndharis/OpenWA.git "$HOME/agent-stack/OpenWA" || warn "OpenWA falhou"

# --- 6. Jarvis (roteador + hook) ---------------------------------------------
say "Instalando Jarvis (roteador semiautônomo)"
mkdir -p "$CLAUDE_DIR/skills/jarvis" "$CLAUDE_DIR/hooks"
cp "$REPO_DIR/skills/jarvis/SKILL.md" "$CLAUDE_DIR/skills/jarvis/SKILL.md"
cp "$REPO_DIR/hooks/jarvis-init.sh"   "$CLAUDE_DIR/hooks/jarvis-init.sh"
chmod +x "$CLAUDE_DIR/hooks/jarvis-init.sh"
ok "Jarvis skill + hook instalados"

# --- 7. settings.json (SessionStart hook) ------------------------------------
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  warn "Já existe settings.json — NÃO sobrescrevi. Adicione o hook SessionStart:"
  echo '   { "type":"command", "command":"bash \"'"$CLAUDE_DIR"'/hooks/jarvis-init.sh\"", "timeout":5 }'
else
  cp "$REPO_DIR/config/settings.template.json" "$CLAUDE_DIR/settings.json"
  ok "settings.json criado a partir do template"
fi

echo ""
ok "Bootstrap completo."
echo ""
echo "Próximos passos MANUAIS (precisam de você):"
echo "  1. hermes setup           # escolher provider + colar API key"
echo "  2. cd ~/agent-stack/OpenWA && npm install && npm run dev   # escanear QR do WhatsApp"
echo "  3. Adicione o bloco 'Modo Jarvis' do config/CLAUDE.snippet.md ao seu CLAUDE.md"
