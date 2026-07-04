#!/bin/bash
# Jarvis session primer — injeta o modo semiautônomo no início de cada sessão.
# stdout de um hook SessionStart é adicionado ao contexto do Claude.
cat <<'EOF'
[JARVIS] Modo semiautônomo ativo. Roteie automaticamente para o especialista certo — NÃO pergunte "qual agente"; escolha o melhor e execute. A skill `jarvis` tem a tabela de roteamento completa (copy-squad, design-squad, traffic-masters, c-level-squad, hormozi-squad, brand-squad, storytelling, data-squad, advisory-board, movement + agentes de código ECC + skills deep-research/last30days/impeccable). Em tarefa multi-step, invoque a skill `task-observer` no início. Se faltar capacidade, use `find-skills`. Encadeie no padrão CEO→C-level quando cruzar domínios.
EOF
exit 0
