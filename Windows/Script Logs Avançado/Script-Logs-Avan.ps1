⚙️ Novos Recursos Implementados:
Compactação ZIP dos logs exportados
Upload para pasta de rede compartilhada (UNC path)
Envio de e-mail com log e anexo ZIP (opcional)
Pronto para agendamento automático
Interface GUI mínima (opcional) para confirmação e exibição de status

📁 Script PowerShell Avançado: Gerenciar-Logs-Avancado.ps1

Add-Type -AssemblyName System.IO.Compression.FileSystem

# ==== CONFIGURAÇÕES ====
$logTypes = @("System", "Application", "Security")
$exportRoot = "C:\Logs\Exportados"
$sharePath = "\\servidor\compartilhamento\logs"
$daysToKeep = 30
$today = Get-Date -Format "yyyy-MM-dd"
$zipName = "Logs_$env:COMPUTERNAME`_$today.zip"
$zipFullPath = "$exportRoot\$zipName"
$emailReport = $true
$showGUI = $true

# ==== EMAIL (opcional) ====
$smtpServer = "smtp.seudominio.com"
$from = "servidor@seudominio.com"
$to = "admin@seudominio.com"
$subject = "Relatório de Logs - $env:COMPUTERNAME ($today)"
$body = ""
$attachment = $zipFullPath

# ==== GUI (opcional) ====
if ($showGUI) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("Iniciando exportação de logs em $env:COMPUTERNAME", "Gerenciamento de Logs")
}

# ==== Criar pasta de exportação ====
if (!(Test-Path $exportRoot)) {
    New-Item -ItemType Directory -Path $exportRoot -Force
}

# ==== Exportar Logs ====
$exportedFiles = @()
foreach ($log in $logTypes) {
    $file = "$exportRoot\$log-$today.evtx"
    wevtutil epl $log $file
    $exportedFiles += $file
    $body += "Log $log exportado para $file`n"
}

# ==== Compactar Logs ====
if (Test-Path $zipFullPath) {
    Remove-Item $zipFullPath -Force
}
[System.IO.Compression.ZipFile]::CreateFromDirectory($exportRoot, $zipFullPath)
$body += "`nLogs compactados para: $zipFullPath`n"

# ==== Upload para pasta de rede ====
if (Test-Path $sharePath) {
    Copy-Item -Path $zipFullPath -Destination $sharePath -Force
    $body += "Arquivo ZIP enviado para $sharePath`n"
} else {
    $body += "Falha ao enviar para $sharePath (caminho inválido)`n"
}

# ==== Limpar logs antigos ====
Get-ChildItem $exportRoot -Recurse -Include *.evtx, *.zip | Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddDays(-$daysToKeep)
} | ForEach-Object {
    $body += "Excluindo arquivo antigo: $($_.FullName)`n"
    Remove-Item $_.FullName -Force
}

# ==== Enviar e-mail ====
if ($emailReport -and (Test-Path $zipFullPath)) {
    Send-MailMessage -SmtpServer $smtpServer -From $from -To $to -Subject $subject -Body $body -Attachments $attachment
    $body += "`nE-mail enviado para $to com o relatório e anexo."
}

# ==== Finalizar ====
Write-Output $body

if ($showGUI) {
    [System.Windows.MessageBox]::Show("Processo concluído!", "Gerenciamento de Logs")
}


📦 Pré-requisitos:
PowerShell 5.1 ou superior
Permissões de administrador
Permissão de gravação na pasta de rede compartilhada
SMTP funcional para envio de e-mail (autenticação pode ser adicionada, se necessário)

📌 Agendamento da Tarefa:
Use o Agendador de Tarefas do Windows:
Ação: Iniciar um programa
Programa/script: powershell.exe
Argumentos: -ExecutionPolicy Bypass -File "C:\Scripts\Gerenciar-Logs-Avancado.ps1"
