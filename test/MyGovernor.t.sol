// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {console} from "forge-std/console.sol";

contract MyGovernorTest is Test {
    GovToken govToken;
    TimeLock timeLock;
    MyGovernor governor;
    Box box;

    address public USER = makeAddr("user");
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    uint256 public constant MIN_DELAY = 3600; // 1 HOUR delay after proposal passed
    uint256 public constant VOTING_DELAY = 7200; // 1 BLOCK
    uint256 public constant VOTING_PERIOD = 50400; // This is how long voting lasts

    // empty address array will means all participants are proposers / executers
    address[] proposers;
    address[] executors;
    address[] targets; // contract to call
    uint256[] values;
    bytes[] calldatas; // which function to call

    function setUp() public {
        govToken = new GovToken();
        govToken.mint(USER, INITIAL_SUPPLY);

        vm.startPrank(USER);
        govToken.delegate(USER);
        timeLock = new TimeLock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(govToken, timeLock);

        // TimeLock roles setting (set as Hashes)
        bytes32 proposerRole = timeLock.PROPOSER_ROLE(); // this role will propose scheduling of operations for single/batch transaction(s)
        bytes32 executorRole = timeLock.EXECUTOR_ROLE(); // this role will execute a ready operation
        bytes32 adminRole = timeLock.TIMELOCK_ADMIN_ROLE();

        // Grant roles to apt. participants
        timeLock.grantRole(proposerRole, address(governor));
        timeLock.grantRole(executorRole, address(0)); // all participants allowed
        timeLock.revokeRole(adminRole, USER);
        vm.stopPrank();

        box = new Box();
        box.transferOwnership(address(timeLock));
    }

    function testUpdateBoxWithoutGovernance() external {
        vm.expectRevert();
        box.storeNumber(1);
    }

    function testGovernorUpdatesBox() external {
        uint256 valueToStore = 888;
        bytes memory encodedFunctionCall = abi.encodeWithSignature(
            "storeNumber(uint256)",
            valueToStore
        );
        string memory description = "Store 1 in Box";

        // Step 1: Propose to Governor
        // preparing params
        targets.push(address(box)); // target contract
        values.push(0);
        calldatas.push(encodedFunctionCall); // function to call with parameter

        // making the proposal call
        uint256 proposalId = governor.propose(
            targets,
            values,
            calldatas,
            description
        );

        // View the state
        console.log(
            "Proposal initial state",
            uint256(governor.state(proposalId))
        );

        // Step 2: Waiting for VOTING_DELAY to pass
        // pushing block state beyond VOTING_DELAY
        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1); // 1 BLOCK was the min delay in the Governor contract

        console.log(
            "Proposal's after delay state",
            uint256(governor.state(proposalId))
        );

        // Step 3: Now we can vote
        string memory reason = "cuz I am supportive!";
        uint8 voteWay = 1; // voting yes
        vm.prank(USER);
        governor.castVoteWithReason(proposalId, voteWay, reason);

        // waiting for the voting period to pass
        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        // Step 4: Queue the proposal with MIN_DELAY. Queuing is done to allow participants who are against the proposal to exit the DAO, if they chose to.
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(targets, values, calldatas, descriptionHash);

        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);

        // Step 5: Execute
        governor.execute(targets, values, calldatas, descriptionHash);
        console.log("Changed Box Value: ", box.getNumber());

        // Finally assert
        assert(box.getNumber() == valueToStore);
    }
}
