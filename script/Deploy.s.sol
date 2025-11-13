// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "../src/DAOContract.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "forge-std/console.sol";


contract Deploy is Script {

    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        address _governanceToken = 0x4495D640EAEbdF22b5B3EadD11514d18056db723;

        DAOContract dao = new DAOContract(
            _governanceToken,
            100 * 10**18,
            10days
        );

        console.log("Storage deployed to", address(dao));
        vm.stopBroadcast();
    }
}