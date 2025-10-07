# PowerShell completions and settings
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# dotnet CLI completions
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# gh CLI completions
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Invoke-Expression -Command $(gh completion -s powershell | Out-String)
}

# terraform completions
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName terraform -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        $env:COMP_LINE = $commandAst.ToString()
        $env:COMP_POINT = $cursorPosition
        terraform | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
        Remove-Item Env:\COMP_LINE, Env:\COMP_POINT -ErrorAction SilentlyContinue
    }
}

# git completions
if (Get-Command git -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        $gitCommands = @('add', 'bisect', 'branch', 'checkout', 'cherry-pick', 'clone', 'commit', 'diff', 'fetch', 'grep', 'init', 'log', 'merge', 'mv', 'pull', 'push', 'rebase', 'reset', 'restore', 'revert', 'rm', 'show', 'stash', 'status', 'switch', 'tag')
        $tokens = $commandAst.ToString() -split ' '
        if ($tokens.Count -eq 2) {
            $gitCommands | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
    }
}

# graphite completions
if (Get-Command gt -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName gt -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        $gtCommands = @('branch', 'commit', 'continue', 'create', 'delete', 'downstack', 'edit', 'feedback', 'fold', 'info', 'init', 'log', 'ls', 'modify', 'move', 'onto', 'repo', 'stack', 'submit', 'sync', 'top', 'track', 'untrack', 'upstack')
        $tokens = $commandAst.ToString() -split ' '
        if ($tokens.Count -eq 2) {
            $gtCommands | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
    }
}
