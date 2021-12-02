#!/bin/zsh

sellAmount=$(printf $1 | xargs | tr -d "\n")
sellAsset=$(printf $2 | xargs | tr -d "\n")
buyAsset=$(printf $3 | xargs | tr -d "\n")

printf "$sellAmount, $sellAsset, $buyAsset"