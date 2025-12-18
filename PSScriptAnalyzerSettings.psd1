@{
    Severity = @('Error','Warning')
    ExcludeRules = @(
        # keep portfolio scripts concise; allow hard-coded sample data in scripts
        'PSUseDeclaredVarsMoreThanAssignments'
    )
    Rules = @{
        PSAvoidUsingWriteHost = @{
            Enable = $true
        }
        PSAvoidUsingPlainTextForPassword = @{
            Enable = $true
        }
        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind = 'space'
        }
    }
}
