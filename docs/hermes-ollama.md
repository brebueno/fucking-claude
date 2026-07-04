# Hermes 24/7 com Ollama local (grátis) — guia do PC parrudo

> **Quando usar:** só num PC com GPU/RAM de verdade. Não rode num Mac 8GB.
> Alvo testado deste guia: **24 GB RAM + RTX 4060 (8 GB VRAM) + Ryzen 5600X.**
> Nesse hardware o Hermes vira um agente autônomo 24/7 com cérebro local
> **grátis e privado** (nenhum token pago). Num Mac M1 8GB, o cérebro é o
> Claude Code — não instale modelo local lá.

O Hermes é grátis (open-source). O que custa é o LLM por trás. Dá pra zerar o
custo de dois jeitos: **Ollama local** (grátis, precisa de GPU) ou **Gemini via
Google AI Studio** (grátis no tier gratuito, nuvem, roda em qualquer máquina).

---

## Opção A — Gemini grátis (funciona em qualquer PC, até Mac 8GB)

Você não precisa de GPU. O **Google AI Studio** dá uma API key gratuita
(tier grátis, independente do app Gemini Pro).

1. Pegue a chave em <https://aistudio.google.com/apikey>.
2. No `~/.hermes/.env` adicione: `GEMINI_API_KEY=suachave`
3. No `~/.hermes/config.yaml`, seção `model:`:
   ```yaml
   model:
     default: "gemini-2.0-flash"     # rápido e grátis; ou gemini-2.5-pro
     provider: "gemini"
   ```
4. Valide: `hermes -p "diga: hermes vivo com gemini"`

Bom pra: rodar o Hermes 24/7 sem GPU, sem gastar, com qualidade decente na nuvem.

---

## Opção B — Ollama local (grátis, privado, precisa de GPU)

## 1. Instalar o Ollama

**Windows:** baixe o instalador em <https://ollama.com/download> (traz suporte CUDA
pra RTX automático). Depois de instalar, o Ollama roda como serviço na bandeja.

**Linux:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**macOS (só se for um Mac parrudo, 16GB+):**
```bash
brew install ollama && brew services start ollama
```

## 2. Baixar o modelo (escolha do cérebro)

Na RTX 4060 (8 GB VRAM) + 24 GB RAM:

| Modelo | Comando | Encaixe | Quando |
|---|---|---|---|
| **Qwen 14B** (recomendado) | `ollama pull qwen2.5:14b` | ~9GB, offload parcial p/ RAM | Melhor qualidade + tool-calling. Cheque a versão mais nova (`ollama` library) — pode já ter Qwen3. |
| **Llama 3.1 8B** (rápido) | `ollama pull llama3.1:8b` | cabe 100% na GPU | Mais veloz, ótimo pra 24/7 |
| **Qwen2.5 7B** | `ollama pull qwen2.5:7b` | 100% GPU | Meio-termo leve |

Teste rápido:
```bash
ollama run qwen2.5:14b "responda só: ok"
```

O servidor OpenAI-compatível do Ollama sobe em `http://localhost:11434/v1`.

## 3. Instalar o Hermes

**Windows (PowerShell):**
```powershell
iex (irm https://hermes-agent.nousresearch.com/install.ps1)
```
**Linux/macOS:**
```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

## 4. Apontar o Hermes pro Ollama

Edite `~/.hermes/config.yaml` (no Windows: `%USERPROFILE%\.hermes\config.yaml`),
na seção `model:`:

```yaml
model:
  default: "qwen2.5:14b"          # o nome do modelo que você puxou no Ollama
  provider: "ollama"               # alias de "custom" — endpoint OpenAI-compatível
  base_url: "http://localhost:11434/v1"
  api_key: "ollama"                # dummy; Ollama local não exige chave
```

Ou pelo wizard: `hermes setup model` → escolha **custom / ollama** → base_url acima.

Valide:
```bash
hermes --model qwen2.5:14b -p "diga: hermes vivo com cerebro local"
```

## 5. Ligar 24/7 + canais (WhatsApp via OpenWA)

```bash
hermes gateway install     # instala o serviço de gateway (mensageria + cron)
hermes setup gateway       # configura canais (Telegram/Discord/WhatsApp/etc.)
```

Pra WhatsApp, suba o **OpenWA** (ver `docs/openwa.md`) e conecte o Hermes ao
endpoint REST dele (`http://localhost:2785/api`, use a API key que o OpenWA gera
no primeiro boot). Assim o Hermes fica reachable pelo teu Zap.

## 6. Cron / jobs autônomos

```bash
hermes setup agent         # define tarefas recorrentes
```
Exemplo de fluxo (bate com o radar de conteúdo): cron diário → skill `last30days`
puxa trends → Hermes te manda o brief no WhatsApp de manhã.

---

## Sanidade / limites

- **VRAM 8GB:** 14B faz offload parcial (usa RAM), fica um pouco mais lento mas
  roda. Se quiser tudo na GPU e mais rápido, use `llama3.1:8b`.
- **Qualidade:** modelo local < Opus. Use o Hermes local pra triagem, avisos,
  automação e tarefas de rotina. Trabalho pesado/criativo continua no Claude Code.
- **Privacidade:** com Ollama, nada sai da máquina. Bom pra dado sensível.
- O `~/.agents/skills` (skill bus) já é compartilhado: `last30days` e
  `task-observer` aparecem no Hermes automaticamente (symlink).
