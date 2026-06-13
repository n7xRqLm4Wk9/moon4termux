#!/usr/bin/env python3
import sys, os, argparse
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from config.settings import WORKSPACE_DIR, load_security_mode, _find_or_create_sandbox
from ai.assistant import Assistant
from ai.router import get_active_label

CY  = "\033[38;2;157;92;255m"  # purple
DIM = "\033[90m"
WB  = "\033[97m"
OR  = "\033[38;2;157;92;255m"
RST = "\033[0m"

BANNER = f"""\
{CY}  ┌──────────────────────────┐
  │{RST} Moon  ·  AI Terminal IDE {CY}│
  │{RST} powered by OpenRouter    {CY}│
  └──────────────────────────┘{RST}"""

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--workspace", "-w", default=None,
                    help="Override workspace dir (bypasses security-mode sandboxing)")
    return p.parse_args()

def get_prompt():
    model = get_active_label().split("(")[0].strip()
    return f"{DIM}[{model}]{RST} {WB}>{RST} "

def resolve_workspace(explicit: str | None) -> tuple[str, str]:
    """Return (workspace_path, security_mode)."""
    mode = load_security_mode()
    if explicit:
        return os.path.abspath(explicit), mode
    if mode in ("medium", "high"):
        return _find_or_create_sandbox(), mode
    return WORKSPACE_DIR, mode

def main():
    args = parse_args()
    workspace, mode = resolve_workspace(args.workspace)
    os.makedirs(workspace, exist_ok=True)

    print()
    print(BANNER)
    print(f"\n{DIM}  workspace : {WB}{workspace}{RST}")
    print(f"{DIM}  security  : {OR}{mode}{RST}")
    print(f"{DIM}  !help · !model · !security · exit{RST}\n")

    assistant = Assistant(workspace, security_mode=mode)

    while True:
        try:
            user_input = input(get_prompt()).strip()
        except (KeyboardInterrupt, EOFError):
            print(f"\n{DIM}  goodbye.{RST}")
            sys.exit(0)

        if not user_input: continue
        if user_input.lower() in ("exit","quit","!exit","!quit"):
            print(f"{DIM}  goodbye.{RST}")
            sys.exit(0)

        try:
            response = assistant.chat(user_input)
            if response:
                print(f"\n{response}\n")
            print(f"{DIM}  \u25ba\u25ba accept edits on  \u00b7  esc to interrupt{RST}")
        except PermissionError as e:
            print(f"\n{WB}  [auth error] {DIM}{e}{RST}\n")
        except ConnectionError as e:
            print(f"\n{WB}  [network] {DIM}{e}{RST}\n")
        except Exception as e:
            print(f"\n{WB}  [error] {DIM}{e}{RST}\n")

if __name__ == "__main__":
    main()
