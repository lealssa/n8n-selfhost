# n8n-selfhost
Instalação local do N8N via container e compose

## Requisitos

- Docker Desktop
- WSL habilitado

## Standalone

Sobe o n8n com persistência local via SQLite. Modo de testes/estudos, não utilizar em produção.

1. Subir aplicação
```powershell
cd ./n8n-standalone/

docker-compose up -d
```

2. Verificar log
```powershell
docker-compose logs n8n
```

Após iniciar, acesse o n8n no endereço http://localhost:5678


## Standalone + DB

Sobe o n8n com persistência no banco de dados Postgres. Carrega também o PGAdmin, para administração web do Postgres.

Ao iniciar, o Postgres irá executar o arquivo `./n8n-db/postgres-init/init.sh`, responsável por criar os bancos do n8n e usuários necessários. Além do banco do n8n, irá criar também um banco para ser usado pelos workflows. Essas configurações estão no `.env.exemplo`.

### Subir

1. Copie o arquivo .env.exemplo para .env e edite ele, alterando o valor das variáveis de acordo.
2. Subir a aplicação
```powershell
cd ./n8n-db/

docker-compose up -d
```
3. Verifique os logs
```powershell
docker-compose logs -f
```   

Após iniciar, acesse o n8n no endereço http://localhost:5678 e o PGAdmin em http://localhost:8080





