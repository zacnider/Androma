<p align="center">
  <img height="100" height="auto" src="https://raw.githubusercontent.com/Nodeist/Kurulumlar/main/logos/jackal.png">
</p>


# Jackal State Sync
Here is a script for you to update `persistent_peers` setting with these peers in `config.toml`.

```
systemctl stop canined
canined tendermint unsafe-reset-all --home $HOME/.canine --keep-addr-book
SNAP_RPC="https://rpc-t-jackal.nodeist.net:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.canine/config/config.toml

```

Restart the node:
```
systemctl restart canined && journalctl -fu canined -o cat
```
