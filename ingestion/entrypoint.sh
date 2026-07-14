echo "$CONFIG_BASE64" | base64 -d > config.yml

/opt/embulk/embulk run config.yml