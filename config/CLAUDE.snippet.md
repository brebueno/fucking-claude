## Modo Jarvis (orquestração semiautônoma)

Operação padrão: **auto-roteamento**. Quando você descreve um objetivo em linguagem natural
(sem nomear agente), o assistente NÃO pergunta "qual agente" — a skill `jarvis` classifica a
intenção e dispara o especialista/squad certo, encadeando no padrão CEO→C-level.

- **Roteador:** skill `jarvis` (tabela completa de qual squad/agente para cada tipo de pedido).
- **Ligado no boot:** hook `SessionStart` (`~/.claude/hooks/jarvis-init.sh`) injeta o modo em toda sessão.
- **Auto-evolução:** `task-observer` roda em tarefas multi-step e melhora as skills sozinho.
- **Lacunas:** `find-skills` (`npx skills find`) busca skill pronta antes de fazer na mão.
- **Sempre-ligado:** Hermes (runtime à parte) + OpenWA (WhatsApp) para operação 24/7 pelo celular.
- **Skill bus:** `~/.agents/skills/` é a fonte única — skill instalada ali aparece no Claude Code E no Hermes.
