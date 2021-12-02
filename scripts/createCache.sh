#!/bin/bash

apiURL="https://polygon.api.0x.org/swap/v1/quote"
sellAmount=$(printf $1 | xargs | tr -d "\n")
sellAsset=$(printf $2 | xargs | tr -d "\n")
buyAsset=$(printf $3 | xargs | tr -d "\n")

curl -s "$apiURL?sellToken=$sellAsset&buyToken=$buyAsset&sellAmount=$sellAmount" > cache.json