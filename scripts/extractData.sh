#!/bin/bash

# Intended to pull data from cache.json

input=$(printf $1 | xargs | tr -d "\n")

data=$(cat cache.json | jq ".$input" | xargs | tr -d "\n" )

# Data is already an encoded string
if [ "$input" = "data" ]; then
    printf $data

elif [ "$input" = "buyAmount" ] ||  [ "$input" = "sellAmount" ]; then
    printf $(seth --to-uint256 $data)

# Addresses can be directly encoded
elif [ "$input" = "sellTokenAddress" ] ||  [ "$input" = "buyTokenAddress" ] ||  [ "$input" = "allowanceTarget" ] ||  [ "$input" = "to" ]; then
    printf $(seth abi-encode 'f(address)' $data)

# Catchall
else
    printf $(in3 abi_encode "string", $data)
fi