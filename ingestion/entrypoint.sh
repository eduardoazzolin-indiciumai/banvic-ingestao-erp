echo "$CONFIG_BASE64" | base64 -d > config.yml.liquid

/opt/embulk/embulk run config.yml.liquid