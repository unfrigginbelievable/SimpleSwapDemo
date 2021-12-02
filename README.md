This repository is a demo of how to use the 0x api to make on-chain swaps.

THIS REPO IS NOT PRODUCTION READY AND IS UNAUDITED.

Please note that this repo has only been tested on OSX.

This repo is only going to work if you fork the Polygon chain. If you want to try on other chains ensure the 0x api is available on it, and change the apiURL in scripts/createCache.sh

You can now run tests either with dapp tools or forge. For forge to work, ensure you fork with a block number, like this:
forge test -f $INFURA_URL --fork-block-number $(latestBlock) --ffi

Install "jq" and "in3" packages in your enviroment to run the scripts.

Dont want to read a lecture of how this repo works? Take a look at SimpleTokenSwap.t.sol for the code.

Now for some spoon feeding:

The big thing to realize is that you must make an http call to the 0x api to get the calldata that is passed onto the swap function.

Take a look at src/SimpleTokenSwap.t.sol to see the swap in action.

There is also a demonstration of the FFI fuction that is part hevm in the test file. FFI allows you to execute shell commands from inside solidity test files. The important thing that took me forever to realize is that any stdout returns from the shell need to be returned abi encoded.

ABI encoding from bash is provided by the in3 package. I'm pretty sure SETH can do that too, but in3 was easier to get working so I ran with it.
