#!/usr/bin/env bash
# ============================================================================
# fucking-claude — bootstrap
# Instala TODOS os agentes, skills, commands, rules e squads numa máquina nova
# e, opcionalmente, os serviços externos (Hermes, OpenWA, impeccable).
# NÃO carrega secret nem dado de cliente.
# ============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"
AGENTS_DIR="$HOME/.agents"
say(){ printf "\033[0;36m→ %s\033[0m\n" "$1"; }
ok(){  printf "\033[0;32m✓ %s\033[0m\n" "$1"; }
warn(){ printf "\033[0;33m! %s\033[0m\n" "$1"; }

# =============================================================================
# NÚCLEO — instala todos os agentes/skills/commands/rules/squads
# =============================================================================
say "Instalando agentes, skills, commands, rules e squads em $CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/commands" \
         "$CLAUDE_DIR/rules" "$CLAUDE_DIR/squads" "$AGENTS_DIR/skills" "$CLAUDE_DIR/hooks"

copy(){ # src_rel dest  — merge não-destrutivo; usa rsync se existir, senão cp
  [ -d "$REPO_DIR/$1" ] || return 0
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$REPO_DIR/$1/" "$2/"
  else
    mkdir -p "$2" && cp -R "$REPO_DIR/$1/." "$2/"
  fi
  ok "$1 → $2"
}
copy agents        "$CLAUDE_DIR/agents"
copy commands      "$CLAUDE_DIR/commands"
copy rules         "$CLAUDE_DIR/rules"
copy skills-claude "$CLAUDE_DIR/skills"
copy agents-skills "$AGENTS_DIR/skills"
copy squads        "$CLAUDE_DIR/squads"

N_AG=$(find "$CLAUDE_DIR/agents" -name '*.md' | wc -l | tr -d ' ')
N_SK=$(find "$CLAUDE_DIR/skills" "$AGENTS_DIR/skills" -name 'SKILL.md' | wc -l | tr -d ' ')
ok "Instalados: $N_AG agentes · $N_SK skills · $(find "$CLAUDE_DIR/commands" -name '*.md'|wc -l|tr -d ' ') commands"

# --- Jarvis: hook de sessão ---------------------------------------------------
if [ -f "$CLAUDE_DIR/skills/jarvis/SKILL.md" ]; then
  cp "$REPO_DIR/hooks/jarvis-init.sh" "$CLAUDE_DIR/hooks/jarvis-init.sh" 2>/dev/null || true
  chmod +x "$CLAUDE_DIR/hooks/jarvis-init.sh" 2>/dev/null || true
  ok "Jarvis instalado (adicione o hook SessionStart do config/settings.template.json ao seu settings.json)"
fi

# =============================================================================
# EXTRAS opcionais — só roda com: bash install.sh --full
# =============================================================================
if [ "${1:-}" = "--full" ]; then
  command -v uv >/dev/null || { say "Instalando uv"; curl -LsSf https://astral.sh/uv/install.sh | sh; }
  if command -v brew >/dev/null; then
    command -v rg >/dev/null || brew install ripgrep || true
    command -v ffmpeg >/dev/null || brew install ffmpeg || true
  fi
  say "impeccable (design)"
  ( cd "$HOME" && printf 'Y\n' | npx --yes impeccable skills install >/dev/null 2>&1 ) || warn "rode 'npx impeccable skills install' manual"
  say "Hermes (agente 24/7, sem setup)"
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup --non-interactive || warn "Hermes falhou"
  say "OpenWA (gateway WhatsApp) em ~/agent-stack/OpenWA"
  mkdir -p "$HOME/agent-stack"
  [ -d "$HOME/agent-stack/OpenWA/.git" ] || git clone --depth 1 https://github.com/rmyndharis/OpenWA.git "$HOME/agent-stack/OpenWA" || warn "OpenWA falhou"
  ok "Extras instalados."
fi

echo ""
ok "Pronto. Reinicie o Claude Code."
echo ""
echo "Passos manuais opcionais:"
echo "  • bash install.sh --full     → instala Hermes/OpenWA/impeccable também"
echo "  • CLAUDE.md                  → cole o bloco de config/CLAUDE.snippet.md"
echo "  • Hermes cérebro grátis      → docs/hermes-ollama.md (Gemini ou Ollama)"
