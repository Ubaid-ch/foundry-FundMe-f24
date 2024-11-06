//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script{
    function run() external{
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.getActiveNetworkConfig().priceFeed;
        vm.startBroadcast();
        new FundMe();
        vm.stopBroadcast();
    }
}