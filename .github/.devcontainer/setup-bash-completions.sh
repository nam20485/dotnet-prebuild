#!/bin/bash
# Setup bash completions for all installed tools

cat >> /etc/bash.bashrc << 'EOF'

# Tool completions
if [ -f /usr/share/bash-completion/bash_completion ]; then . /usr/share/bash-completion/bash_completion; fi

# Ansible completions (argcomplete-based)
if command -v register-python-argcomplete >/dev/null 2>&1; then 
    eval "$(register-python-argcomplete ansible)"
    eval "$(register-python-argcomplete ansible-galaxy)"
fi

# dotnet completions
export DOTNET_CLI_TELEMETRY_OPTOUT=1
_dotnet_bash_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n'
  local candidates=$(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)
  COMPREPLY=($(compgen -W "$candidates" -- "$cur"))
}
complete -f -F _dotnet_bash_complete dotnet

# gh completions
if command -v gh >/dev/null 2>&1; then eval "$(gh completion -s bash)"; fi

# gcloud completions
if [ -f /usr/lib/google-cloud-sdk/completion.bash.inc ]; then . /usr/lib/google-cloud-sdk/completion.bash.inc; fi

# terraform completions
if command -v terraform >/dev/null 2>&1; then complete -C /usr/bin/terraform terraform; fi

# npm completions
if command -v npm >/dev/null 2>&1; then eval "$(npm completion 2>/dev/null)"; fi

# bun completions
if command -v bun >/dev/null 2>&1; then
  [ -s "/home/vscode/.bun/_bun" ] && . "/home/vscode/.bun/_bun"
fi

# uv completions
if command -v uv >/dev/null 2>&1; then eval "$(uv generate-shell-completion bash)"; fi

# graphite completions
if command -v gt >/dev/null 2>&1; then eval "$(gt completion)"; fi

EOF
