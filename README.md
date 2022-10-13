# Docker Telegram Bot API

## Supported versions

- 6.2

## Pull

### Docker Hub

#### Ubuntu

```
docker pull dwreg/telegram-bot-api
docker pull dwreg/telegram-bot-api:<version>
```

#### Alpine

```
docker pull dwreg/telegram-bot-api:alpine
docker pull dwreg/telegram-bot-api:<version>-alpine
```

### Darkwolf Registry

#### Ubuntu

```
docker pull registry.darkwolf.cloud/telegram-bot-api
docker pull registry.darkwolf.cloud/telegram-bot-api:<version>
```

#### Alpine

```
docker pull registry.darkwolf.cloud/telegram-bot-api:alpine
docker pull registry.darkwolf.cloud/telegram-bot-api:<version>-alpine
```

## Build

### Ubuntu

```
docker buildx build \
  --build-arg BASE=ubuntu \
  --build-arg UBUNTU_VERSION=<version> \
  --build-arg TELEGRAM_BOT_API_VERSION=<version> \
  --build-arg UID=<uid> \
  --build-arg GID=<gid> \
  --target deploy \
  -t telegram-bot-api:<version> .
```

### Alpine

```
docker buildx build \
  --build-arg BASE=alpine \
  --build-arg ALPINE_VERSION=<version> \
  --build-arg TELEGRAM_BOT_API_VERSION=<version> \
  --build-arg UID=<uid> \
  --build-arg GID=<gid> \
  --target deploy \
  -t telegram-bot-api:<version>-alpine .
```
