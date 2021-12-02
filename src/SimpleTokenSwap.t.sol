// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
pragma experimental ABIEncoderV2;

import "ds-test/test.sol";
import "ds-math/math.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@dapp-cheats/TokenCheats.sol";
import "@dapp-cheats/TypeConverts.sol";
import "./SimpleTokenSwap.sol";

contract SimpleTokenSwapTest is
    DSTest,
    DSMath,
    TokenCheats,
    Ownable,
    SimpleTokenSwap,
    TypeConverts
{
    IERC20 DAI = IERC20(0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063);
    IERC20 WETH = IERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);
    IERC20 WMATIC = IERC20(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
    IERC20 BIFI = IERC20(0xFbdd194376de19a88118e84E279b977f165d01b8);
    IERC20 sellTkn = WETH;
    IERC20 buyTkn = DAI;

    string constant scriptPath = "scripts/extractData.sh";

    function setUp() public {}

    function test_swap() public {
        uint256 giveAmount = 100 ether;
        uint256 swapAmount = 80 ether;
        uint256 swapTolerance = 0.01 ether; // 1%

        // TODO: How does this work with non-18 decimal assets?

        // Give this contract a ton of the sell token
        giveTokens(address(this), sellTkn, giveAmount);
        assertEq(sellTkn.balanceOf(address(this)), giveAmount);

        // Cache results from 0x-api
        // The api can search by asset symbol or by address
        // You will have significantly better luck if you only use addresses
        string[] memory inputs = new string[](5);
        inputs[0] = "bash";
        inputs[1] = "scripts/createCache.sh";
        inputs[2] = uint2str(swapAmount);
        inputs[3] = addressToString(address(sellTkn));
        inputs[4] = addressToString(address(buyTkn));
        hevm.ffi(inputs);

        IERC20 sellToken = IERC20(fetchData_address("sellTokenAddress"));
        emit log_named_address("Sell Address", address(sellToken));

        IERC20 buyToken = IERC20(fetchData_address("buyTokenAddress"));
        emit log_named_address("Buy Address", address(buyToken));

        address spender = fetchData_address("allowanceTarget");
        emit log_named_address("Spender", spender);

        address payable swapTarget = payable(fetchData_address("to"));
        emit log_named_address("Swap Target", address(swapTarget));

        bytes memory swapCallData = fetchData_bytes("data");
        // emit log_bytes(swapCallData); // <- spits out a ton of hex

        uint256 buyAmount = abi.decode(fetchData_bytes("buyAmount"), (uint256));
        emit log_named_uint("Buy Amount", buyAmount);

        uint256 sellAmount = abi.decode(
            fetchData_bytes("sellAmount"),
            (uint256)
        );
        emit log_named_uint("Sell Amount", sellAmount);

        // Do the swap
        fillQuote(
            sellToken,
            buyToken,
            spender,
            swapTarget,
            swapCallData,
            sellAmount
        );

        // Remove the cache
        inputs = new string[](2);
        inputs[0] = "bash";
        inputs[1] = "scripts/removeCache.sh";
        hevm.ffi(inputs);

        // Test with a 1% tolerance
        assertGe(
            buyToken.balanceOf(address(this)),
            buyAmount - wmul(buyAmount, swapTolerance)
        );
    }

    function testFail_swap() public {
        // Shouldn't be able to trade the same asset to itself
        fillQuote(
            WETH,
            WETH,
            address(WETH),
            payable(address(WETH)),
            bytes("test"),
            1 ether
        );
    }

    function fetchData_address(string memory key)
        public
        returns (address output)
    {
        output = abi.decode(fetchData_bytes(key), (address));
    }

    function fetchData_bytes(string memory key)
        public
        returns (bytes memory output)
    {
        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = scriptPath;
        inputs[2] = key;

        output = hevm.ffi(inputs);
    }
}
