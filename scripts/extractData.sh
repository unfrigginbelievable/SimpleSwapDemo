#!/bin/bash

# Intended to pull data from cache.json

input=$(printf $1 | xargs | tr -d "\n")

data=$(cat cache.json | jq ".$input" | xargs | tr -d "\n" )

# Data is already an encoded string
if [ "$input" = "data" ]; then
    printf $data

# Large ints must be converted to hex, then encoded
elif [ "$input" = "buyAmount" ] ||  [ "$input" = "sellAmount" ]; then
    hex=$(printf "0x"$( echo "obase=16; $data" | bc ))
    printf $(in3 abi_encode uint256 $hex)

# Addresses can be directly encoded
elif [ "$input" = "sellTokenAddress" ] ||  [ "$input" = "buyTokenAddress" ] ||  [ "$input" = "allowanceTarget" ] ||  [ "$input" = "to" ]; then
    printf $(in3 abi_encode address $data)

# Catchall
else
    printf $(in3 abi_encode "string", $data)
fi