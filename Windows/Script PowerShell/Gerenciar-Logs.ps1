📁 Objetivo do Script:
Exportar logs dos principais logs de eventos (Sistema, Aplicativo e Segurança)
Arquivar os logs por data
Apagar eventos com mais de X dias
(Opcional) Enviar relatório por e-mail

💻 Script PowerShell: Gerenciar-Logs.ps1

# Configurações
$logTypes = @("System", "Application", "Security")
$exportPath = "C:\Logs\Exportados"
$daysToKeep = 30
$today = Get-Date -Format "yyyy-MM-dd"
$emailReport = $true

# Configurações de e-mail (opcional)
$smtpServer = "smtp.seudominio.com"
$from = "servidor@seudominio.com"
$to = "admin@seudominio.com"
$subject = "Relatório de Logs - $env:COMPUTERNAME ($today)"
$body = ""

# Criar pasta de exportação se não existir
if (!(Test-Path $exportPath)) {
    New-Item -ItemType Directory -Path $exportPath -Force
}

# Exportar logs
foreach ($log in $logTypes) {
    $fileName = "$exportPath\$log-$today.evtx"
    wevtutil epl $log $fileName
    $body += "Log $log exportado para $fileName`n"
}

# Limpar logs antigos
Get-ChildItem $exportPath -Recurse -Include *.evtx | Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddDays(-$daysToKeep)
} | ForEach-Object {
    $body += "Excluindo log antigo: $($_.FullName)`n"
    Remove-Item $_.FullName -Force
}

# (Opcional) Enviar relatório por e-mail
if ($emailReport) {
    Send-MailMessage -SmtpServer $smtpServer -From $from -To $to -Subject $subject -Body $body
}

Write-Output "Processo concluído em $today"

✅ O que esse script faz:
Exporta os logs do sistema, aplicativo e segurança em .evtx
Organiza os arquivos por data no diretório C:\Logs\Exportados
Remove arquivos antigos (mais de 30 dias)
(Opcional) envia um e-mail com o relatório das operações executadas

🛡️ Permissões Necessárias:
Execução como administrador (para acesso aos logs e envio de e-mails)
Permissões no diretório de exportação
Se envio de e-mail for habilitado, SMTP funcional e credenciais se necessário

🔄 Agendamento:
Você pode agendar a execução usando o Agendador de Tarefas do Windows com uma tarefa diária, semanal, etc.
