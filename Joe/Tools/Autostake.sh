#!/bin/bash
echo "=================================================="
echo "   _  ______  ___  __________________";
echo "  / |/ / __ \/ _ \/ __/  _/ __/_  __/";
echo " /    / /_/ / // / _/_/ /_\ \  / /   ";
echo "/_/|_/\____/____/___/___/___/ /_/    ";
echo -e "\e[0m"
echo "=================================================="


sleep 2

############ SET PROPERTIES #########

ADDRESS="walletadress"
VALIDATOR="valoperadress"
KEY_NAME="walletname"
PASS="walletpass"
CHAIN_ID="chainid"
GAS_VALUE="auto"
#FEE_VALUE=""

############ AUTO DELEGATION #########

# Withdraw
while :
do
	echo $PASS | joed tx distribution withdraw-rewards "${VALIDATOR}"  --from "${KEY_NAME}" --commission --chain-id=${CHAIN_ID} --gas="${GAS_VALUE}" -y

	sleep 20s

	AVAILABLE_COIN=$(joed query bank balances ${ADDRESS} --output json | jq -r '.balances | map(select(.denom == "ujoe")) | .[].amount' | tr -cd [:digit:])
	KEEP_FOR_FEES=100000
	AMOUNT=$(($AVAILABLE_COIN - $KEEP_FOR_FEES))
	AMOUNT_FINAL=$AMOUNT"ujoe"


	# Delegate
	echo $PASS | joed tx staking delegate "${VALIDATOR}" "${AMOUNT_FINAL}" --from "${KEY_NAME}" --chain-id=${CHAIN_ID} -y
	date
	sleep 90s
done;
