#!/bin/sh
set -e


if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for machinecoind"

  set -- machinecoind "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "machinecoind" ]; then
  mkdir -p "$MACHINECOIN_DATA"
  chmod 700 "$MACHINECOIN_DATA"
  chown -R machinecoin "$MACHINECOIN_DATA"

  echo "$0: setting data directory to $MACHINECOIN_DATA"

  set -- "$@" -datadir="$MACHINECOIN_DATA" -conf="$MACHINECOIN_CONFIG"
fi

cat >${MACHINECOIN_CONFIG} <<EOF
server=1

rpcuser=${MACHINECOIN_RPCUSER:-machinecoin}
rpcpassword=${MACHINECOIN_RPCPASSWORD:-changemeplzasap}
rpcallowip=${MACHINECOIN_RPCALLOWIP:-127.0.0.1}

printtoconsole=${MACHINECOIN_PRINTTOCONSOLE:-1}

masternode=${MACHINECOIN_MASTERNODE}
masternodeprivkey=${MACHINECOIN_MASTERNODE_KEY}
externalip=${MACHINECOIN_MASTERNODE_IP}:40333

txindex=1
EOF

if [ "$1" = "machinecoind" ] || [ "$1" = "machinecoin-cli" ] || [ "$1" = "machinecoin-tx" ]; then
  echo
  exec gosu machinecoin "$@"
fi

echo
exec "$@"
cron start
