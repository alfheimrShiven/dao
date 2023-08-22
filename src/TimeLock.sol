// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract TimeLock is TimelockController {
    /**
    minDelay: Is the waiting time before execution for participants to opt out of the DAO if they will.
    proposers: People who can propose. Should be all participants of the DAO.
    executors: People who can execute. Should be all participants of the DAO.
     */
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors
    ) TimelockController(minDelay, proposers, executors, msg.sender) {}
}
