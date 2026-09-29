# Verifica se o script está rodando como Administrador (Obrigatório para gerenciar hardware)
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Solicitando privilégios de administrador..." -ForegroundColor Cyan
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Carrega os assemblies necessários para a interface gráfica
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Cria a janela principal (Form)
$form = New-Object System.Windows.Forms.Form
$form.Text = "MakerPS2EXE"
$form.Size = New-Object System.Drawing.Size(420, 240)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# 1. Campo para o Arquivo de Entrada (-inputFile)
$lblInput = New-Object System.Windows.Forms.Label
$lblInput.Location = New-Object System.Drawing.Point(15, 20)
$lblInput.Size = New-Object System.Drawing.Size(120, 20)
$lblInput.Text = "Arquivo .ps1 (Entrada):"
$form.Controls.Add($lblInput)

$txtInput = New-Object System.Windows.Forms.TextBox
$txtInput.Location = New-Object System.Drawing.Point(140, 17)
$txtInput.Size = New-Object System.Drawing.Size(240, 20)
$form.Controls.Add($txtInput)

# 2. Campo para o Arquivo de Saída (-outputFile)
$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.Location = New-Object System.Drawing.Point(15, 60)
$lblOutput.Size = New-Object System.Drawing.Size(120, 20)
$lblOutput.Text = "Arquivo .exe (Saída):"
$form.Controls.Add($lblOutput)

$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Location = New-Object System.Drawing.Point(140, 57)
$txtOutput.Size = New-Object System.Drawing.Size(240, 20)
$form.Controls.Add($txtOutput)

# 3. Campo para o Ícone (-iconFile)
$lblIcon = New-Object System.Windows.Forms.Label
$lblIcon.Location = New-Object System.Drawing.Point(15, 100)
$lblIcon.Size = New-Object System.Drawing.Size(120, 20)
$lblIcon.Text = "Arquivo .ico (Ícone):"
$form.Controls.Add($lblIcon)

$txtIcon = New-Object System.Windows.Forms.TextBox
$txtIcon.Location = New-Object System.Drawing.Point(140, 97)
$txtIcon.Size = New-Object System.Drawing.Size(240, 20)
$form.Controls.Add($txtIcon)

# Botão de Compilar
$btnCompile = New-Object System.Windows.Forms.Button
$btnCompile.Location = New-Object System.Drawing.Point(140, 140)
$btnCompile.Size = New-Object System.Drawing.Size(120, 35)
$btnCompile.Text = "Compilar"
$form.Controls.Add($btnCompile)

# Ação ao clicar no botão
$btnCompile.Add_Click({
    $inputFile = $txtInput.Text
    $outputFile = $txtOutput.Text
    $iconFile = $txtIcon.Text

    # Validação básica
    if ([string]::IsNullOrWhiteSpace($inputFile) -or [string]::IsNullOrWhiteSpace($outputFile)) {
        [System.Windows.Forms.MessageBox]::Show("Os campos de Entrada (.ps1) e Saída (.exe) são obrigatórios.", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    try {
        # Muda o cursor para "Carregando"
        $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor

        # Verifica se o campo de ícone foi preenchido para montar o comando corretamente
        # Removido o parâmetro -Quiet que estava causando o erro
        if ([string]::IsNullOrWhiteSpace($iconFile)) {
            Invoke-ps2exe -inputFile $inputFile -outputFile $outputFile -noConsole
        } else {
            Invoke-ps2exe -inputFile $inputFile -outputFile $outputFile -iconFile $iconFile -noConsole
        }

        # Restaura o cursor e exibe sucesso
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
        [System.Windows.Forms.MessageBox]::Show("O script foi compilado com sucesso!", "Sucesso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    
    } catch {
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
        [System.Windows.Forms.MessageBox]::Show("Ocorreu um erro ao compilar:`n$($_.Exception.Message)", "Erro", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Exibe a interface gráfica
$form.ShowDialog() | Out-Null