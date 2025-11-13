// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import { DAOContract } from "../src/DAOContract.sol";

contract CreateProposal is Script {
    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address daoAddress = vm.envAddress("DAO_ADDRESS");

        vm.startBroadcast(pk);
        DAOContract dao = DAOContract(daoAddress);

        dao.createProposal("Proposal to improve something");

        vm.stopBroadcast();
    }
}