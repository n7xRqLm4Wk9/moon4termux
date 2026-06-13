# Moon

A terminal AI coding assistant for Termux on Android. Chat in plain
English — Moon reads and writes files, runs commands, runs tests, lints
code, and fixes its own mistakes in a loop, all from a single REPL.

# Note

Moon currently does not support IOS, Windows, Mac. Although are currently planning to add support in future updates.

```
  ┌──────────────────────────┐
  │ Moon  ·  AI Terminal IDE      │
  │ powered by OpenRouter         │
  └──────────────────────────┘
```

## Features

- **Natural-language file edits** — "add a login form to App.jsx", "fix the
  off-by-one in pagination.py"
- **Runs and fixes its own output** — writes a file, runs it, feeds errors
  back to the model, retries (up to 3 times)
- **Security modes** — `low` (broad filesystem access), `medium` (sandboxed
  to a dedicated project folder), `high` (sandboxed + every command needs
  manual approval)
- **Search mode** — paste a URL (including GitHub file links) and Moon
  fetches the content as context automatically
- **Built-in test runner, linter, git status/diff, undo, cost tracking**
- **30+ models** via OpenRouter — free agentic/coding models by default, or
  bring your own OpenAI/Anthropic/Gemini/custom API key

## Install (Termux)

```bash
pkg update -y && pkg install -y python git curl
pip install -q --break-system-packages requests
```

Copy the `moon` folder into your home directory:

```bash
rm -rf $HOME/flow && cp -r /Download/moon $HOME/moon && echo "finished"```

Add your OpenRouter API key (free models work without payment — get a key
at [openrouter.ai/keys](https://openrouter.ai/keys)):

```bash
echo 'export OPENROUTER_API_KEY="your_key_here"' >> ~/.bashrc
```

Set up the `moon` command:

```bash
echo "alias moon='python \$HOME/moon/main.py'" >> ~/.bashrc
source ~/.bashrc
```

Run it:

```bash
moon
```

## Usage

Just type what you want:

```
> add a function to utils.py that validates email addresses
> fix the failing test in test_auth.py
> explain how the context engine works
```

### Commands

| Command | Description |
|---|---|
| `!model` | Switch the active model |
| `!default <n>` | Set and save a default model |
| `!status` | Model, security mode, branch, file count, cost |
| `!cost` | Token/cost summary for this session |
| `!git` | Branch, status, diff, recent commits |
| `!tree` | Project file tree |
| `!read <file>` | Read a file |
| `!run <cmd>` | Run a shell command |
| `!delete <file>` | Delete a file (with confirmation) |
| `!mkdir <dir>` | Create a directory |
| `!test [target]` | Run all tests, or a specific test |
| `!analyse [path]` / `!lint [path]` | AI-driven bug analysis / linting |
| `!log [file]` | Tail a log file |
| `!search <term>` | Search the workspace for text |
| `!sync [path]` | Replace `~/moon` from another folder (e.g. `/sdcard`) |
| `!undo` | Revert the last AI-made changes |
| `!autorun true/false` | Toggle whether AI shell commands run automatically |
| `!searchmode true/false` | Toggle automatic URL/GitHub-file fetching |
| `!security [low\|medium\|high]` | View or change the security mode |
| `!clear` | Clear conversation history |

`/`-prefixed aliases (`/model`, `/tree`, `/status`, etc.) work the same way.

## Security modes

Run `!security` to see your current mode, or `!security <mode>` to switch
(restart Moon to apply):

- **low** — full access to the workspace, your home directory, `/sdcard`,
  and `/storage`. System directories (`/proc`, `/etc`, `/bin`, etc.) are
  always blocked.
- **medium** — sandboxed to `/sdcard/moon-prj` (created automatically).
  Commands follow `!autorun`.
- **high** — same sandbox as medium, but every AI-issued command requires
  your manual y/n approval, regardless of `!autorun`.

## Search mode

On by default. When you paste a URL — including a `github.com/.../blob/...`
link — Moon fetches the raw content and includes it as context for the
model. Toggle with `!searchmode true/false`.

## API keys

Moon reads keys from environment variables, falling back to
`config/api_key.env` (copy `config/api_key.env.example` and fill it in).
Exported env vars (e.g. in `~/.bashrc`) take priority.

| Variable | Used for |
|---|---|
| `OPENROUTER_API_KEY` | OpenRouter models (default — most models in `!model`) |
| `OPENAI_API_KEY` | Direct OpenAI models |
| `ANTHROPIC_API_KEY` | Direct Anthropic models |
| `GEMINI_API_KEY` | Direct Gemini models |
| `API_CUSTOM` + `API_CUSTOM_KEY` | Any OpenAI-compatible custom endpoint |

## License

MIT
