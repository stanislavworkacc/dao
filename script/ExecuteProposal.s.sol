// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Script} from "forge-std/Script.sol";
import { DAOContract } from "../src/DAOContract.sol";

contract ExecuteProposal is Script {
    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address daoAddress = vm.envAddress("DAO_ADDRESS");

        vm.startBroadcast(pk);
        DAOContract dao = DAOContract(daoAddress);

        dao.executeProposal(1, true);

        vm.stopBroadcast();
    }
}