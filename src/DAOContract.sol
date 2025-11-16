// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;


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

    uint256 public constant QUORUM_PERCENTAGE = 50;
    uint256 public minTokensToCreateProposal;
    uint256 public proposalCount;
    uint256 public votingPeriod = 3 days;

    mapping(uint256 => Proposal) public proposals; //key id - value proposal
    mapping(uint256 => mapping(address => bool)) public hasVoted;


    Proposal[] public proposalsArray;

    IERC20 public immutable GOVERNANCE_TOKEN;

    event ProposalCreated(uint256 id, string description, address creator);
    event ProposalExecuted(uint256 id);
    event Voted(uint256 id, address voter, bool suport, uint amount);

    constructor(address _governanceToken, uint _minTokensToCreateProposal, uint _votingPeriod) Ownable(msg.sender) {
        require(_governanceToken != address(0), "DAO: governance token is zero address");
        require(_votingPeriod > 0, "DAO: Voting period must be greater than 0");
        GOVERNANCE_TOKEN = IERC20(_governanceToken);
        minTokensToCreateProposal = _minTokensToCreateProposal;
        votingPeriod = _votingPeriod;
    }


    function createProposal(string memory _description) external onlyOwner {
        require(bytes(_description).length > 0, "DAO: description can't be empty");

        require(GOVERNANCE_TOKEN.balanceOf(msg.sender) >= minTokensToCreateProposal, 'DAO: insufficient balance to create proposal');
        proposalCount++;
        uint currentId = proposalCount;
        uint deadline = block.timestamp + votingPeriod;

        proposals[proposalCount] = Proposal({
            id: currentId,
            description: _description,
            executed: false,
            voteCountFor: 0,
            voteCountAgainst: 0,
            deadline: deadline
        });

        emit ProposalCreated(currentId, _description, msg.sender);
    }

    function vote(uint _proposalId, bool _support) external {
        Proposal storage proposal = proposals[_proposalId];

        require(_proposalId > 0 && _proposalId <= proposalCount, "DAO: Invalid proposal id");
        require(block.timestamp < proposal.deadline, "DAO: voting period has ended");

        uint voterBalance = GOVERNANCE_TOKEN.balanceOf(msg.sender);

        require(!hasVoted[_proposalId][msg.sender], "DAO: voter has already voted on this proposal");
        require(voterBalance > 0, "DAO: insufficient voter balance");

        if (_support) {
            proposal.voteCountFor += voterBalance;
        } else {
            proposal.voteCountAgainst += voterBalance;
        }

        emit Voted(_proposalId, msg.sender, _support, voterBalance);
    }

    modifier proposalReadyToExecute(uint _proposalId, bool _ignoreVotingPeriod) {
        validateProposalForExecution(_proposalId, _ignoreVotingPeriod);
        _;
    }

    function validateProposalForExecution(uint _proposalId, bool _ignoreVotingPeriod) public view {
        require(_proposalId > 0 && _proposalId <= proposalCount, "DAO: invalid proposal ID");

        Proposal storage proposal = proposals[_proposalId];

        require(!proposal.executed, "DAO: proposal has already been executed");
        require(_ignoreVotingPeriod || block.timestamp >= proposal.deadline, "DAO: voting period is still active");

        uint totalVotes = proposal.voteCountFor + proposal.voteCountAgainst;
        require(totalVotes > 0, "DAO: no votes cast for this proposal");

        uint quorum = (totalVotes * QUORUM_PERCENTAGE) / 100;
        require(proposal.voteCountFor > quorum, "DAO: proposal did not reach quorum");
    }

    function executeProposal(uint _proposalId, bool _ignoreVotingPeriod) external onlyOwner proposalReadyToExecute(_proposalId, _ignoreVotingPeriod) {
        Proposal storage proposal = proposals[_proposalId];

        proposal.executed = true;

        emit ProposalExecuted(_proposalId);
    }

    function getProposal(uint _proposalId) view external returns (Proposal memory) {
        return proposals[_proposalId];
    }

    function setMiniumTokenToCreateProposal(uint256 _minTokensToCreateProposal) public onlyOwner {
        minTokensToCreateProposal = _minTokensToCreateProposal;
    }

    function setVotingPeriod(uint256 _votingPeriod) public onlyOwner {
        votingPeriod = _votingPeriod;
    }
}