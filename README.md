# Decentralised Autonomous Organisation (DAO) 🏛️

## About
In this project, I demonstrate the process involved in running a DAO. Below are the steps involved in executing a task through a DAO:

**Step 1:** Granting roles to participants using TimeLock contract.

**Step 2:** Making a proposal to the Governor.

**Step 3:** Voting takes place post the voting delay.

**Step 4:** Queuing the proposal post the voting period. This is done to allow the participants who were against the proposal to leave the DAO if they wish to.
 
**Step 5:** Execution of the proposal.

## Reference
[OpenZeppelin Governance](https://docs.openzeppelin.com/contracts/4.x/governance)

## Usage
### OpenZeppelin

[OpenZeppelin GitHub Repo](https://github.com/OpenZeppelin/openzeppelin-contracts)
<br>

### Installing OpenZeppelin Contracts Package

```bash
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```


## Quickstart 🚀
```
git clone https://github.com/alfheimrShiven/dao.git
cd dao
forge build
```

## Testing
`forge test`

or

`forge test --fork-url $SEPOLIA_RPC_URL`

#### Test coverage
`forge coverage`

# Thank you! 🤗

If you appreciated this, feel free to follow me:

[![Shivens LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/shivends/)

[![Shivens Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/shiven_alfheimr)
