#!/bin/sh

set -eu

DISTRO="$(cat /etc/os-release | sed -n 's/^ID=//p')"
TELEGRAM_BOT_API_DATA='/var/lib/telegram-bot-api'
TELEGRAM_BOT_API_TEMPORARY_DATA='/var/tmp/telegram-bot-api'
TELEGRAM_BOT_API_LOGS='/var/log/telegram-bot-api'
TELEGRAM_BOT_API_DEBUG_LOG_FILE="${TELEGRAM_BOT_API_LOGS}/debug.log"

if [ "$(echo $1 | cut -c1)" = '-' ]; then
  set -- telegram-bot-api "$@"
fi

if [ "$1" = 'telegram-bot-api' ]; then
  mkdir -p \
    "${TELEGRAM_BOT_API_DATA}" \
    "${TELEGRAM_BOT_API_TEMPORARY_DATA}" \
    "${TELEGRAM_BOT_API_LOGS}"
  touch \
    "${TELEGRAM_BOT_API_DEBUG_LOG_FILE}"
  chown -R telegram-bot-api:telegram-bot-api \
    "${TELEGRAM_BOT_API_DATA}" \
    "${TELEGRAM_BOT_API_TEMPORARY_DATA}" \
    "${TELEGRAM_BOT_API_LOGS}"

  set -- "$@" \
    --dir="${TELEGRAM_BOT_API_DATA}" \
    --temp-dir="${TELEGRAM_BOT_API_TEMPORARY_DATA}" \
    --log="${TELEGRAM_BOT_API_DEBUG_LOG_FILE}"

  if [ "${DISTRO}" = 'alpine' ]; then
    exec su-exec telegram-bot-api "$@"
  else
    exec gosu telegram-bot-api "$@"
  fi
fi

exec "$@"
