🎯 Objetivo
Rotacionar os logs de um serviço fictício (/var/log/minhaapp/*.log) semanalmente, mantendo 4 arquivos antigos, compactando-os e reiniciando o serviço após a rotação.

📄 Arquivo de configuração: /etc/logrotate.d/minhaapp

/var/log/minhaapp/*.log {
    weekly                 # Roda semanalmente
    rotate 4              # Mantém 4 arquivos antigos
    compress              # Compacta os logs antigos com gzip
    delaycompress         # Adia a compressão até a próxima rotação
    missingok             # Não dá erro se o log não existir
    notifempty            # Não roda se o log estiver vazio
    create 0640 root adm  # Cria novo log com permissões definidas
    postrotate
        # Reinicia o serviço para que ele comece a escrever no novo arquivo de log
        systemctl reload minhaapp > /dev/null 2>&1 || true
    endscript
}


🛠️ Como testar a configuração
Você pode testar a configuração do logrotate com o comando:

logrotate --debug /etc/logrotate.d/minhaapp
Para forçar a rotação manualmente:

logrotate -f /etc/logrotate.d/minhaapp

📦 Dica Extra: Verificar logrotate global
O arquivo principal de configuração do logrotate é:

/etc/logrotate.conf
Ele pode conter diretivas globais e incluir o diretório /etc/logrotate.d/, como:

include /etc/logrotate.d
