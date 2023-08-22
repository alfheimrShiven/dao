// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {TimeLock} from "../src/TimeLock.sol";

contract MyGovernorTest is Test {
    GovToken govToken;
    TimeLock timeLock;
    MyGovernor governor;
    Box box;

    address public USER = makeAddr("user");
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    uint256 public constant MIN_DELAY = 3600; // 1 HOUR delay after proposal passed
    // empty address array will means all participants are proposers / executers
    address[] proposers;
    address[] executors;

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
}
