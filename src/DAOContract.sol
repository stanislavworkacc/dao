// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DAOContract is Ownable {
    struct Proposal {
        uint256 id;
        string description;
        bool executed;
        uint256 voteCountFor;
        uint256 voteCountAgainst;
        uint256 deadline;
    }

    uint256 public constant QUORUM_PERCENTAGE = 51;
    uint256 public proposalCount;

    mapping(uint256 => Proposal) public proposals; //key id - value proposal
    Proposal[] public proposalsArray;

    IERC20 public governanceToken;

    event ProposalCreated(uint256 id, string description);
    event ProposalExecuted(uint256 id);
    event Voted(uint256 id, address voter, bool suport, uint amount);

    constructor() Ownable(msg.sender) {}
}