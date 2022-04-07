#!/usr/bin/zsh

# activate the virtual env
source /home/zet/dev/cairo/cairo_venv/bin/activate

CONTRACT_NAME=$1
CONTRACT_PATH="contracts/$1.cairo"
COMPILE_PATH="artifacts/$1.json"
ABI_PATH="artifacts/abis/$1.json"

echo -e "Contract path ($CONTRACT_PATH): \c"
read CONTRACT_OVERRIDE

if [[ $CONTRACT_OVERRIDE != "" ]]
then
  CONTRACT_PATH=$CONTRACT_OVERRIDE
fi

echo -e "Artifact path ($COMPILE_PATH): \c"
read COMPILE_OVERRIDE

if [[ $COMPILE_OVERRIDE != "" ]]
then
  COMPILE_PATH=$COMPILE_OVERRIDE
fi

echo -e "ABI path ($ABI_PATH): \c"
read ABI_OVERRIDE

if [[ $ABI_OVERRIDE != "" ]]
then
  ABI_PATH=$ABI_OVERRIDE
fi

echo "Compiling $1..."
starknet-compile $CONTRACT_PATH \
--output=$COMPILE_PATH \
--abi=$ABI_PATH
echo "Done"
