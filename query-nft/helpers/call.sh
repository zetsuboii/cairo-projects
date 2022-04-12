#!/usr/bin/zsh

# CONTINUE

CONTRACT_NAME=$1
FUNCTION_NAME=$2
CONTRACT_ADDR=$3
ABI_PATH="artifacts/abis/$1.json"

if [[ $CONTRACT_ADDR == "" ]]
then
  echo -e "Contract address: \c"
  read CONTRACT_ADDR
fi

echo -e "ABI address ($ABI_PATH): \c"
read ABI_OVERRIDE
if [[ $ABI_OVERRIDE != "" ]]
then
  ABI_PATH = $ABI_OVERRIDE 
fi

echo -e "Input for the $FUNCTION_NAME function: \c"
read INPUTS
echo $INPUTS

if [[ $INPUTS == "" ]]
then
  starknet call \
   --address=$QUERY_ADDR \
   --abi=$ABI_PATH \
   --function=$FUNCTION_NAME
else
  starknet call \
   --address=$QUERY_ADDR \
   --abi=$ABI_PATH \
   --function=$FUNCTION_NAME
   --inputs=$INPUTS
fi
