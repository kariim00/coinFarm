# CoinFarm

Welcome to the CoinFarm repository! CoinFarm is a yield farming DAPP that rewards users with a reward token for staking a staking token. It is written in Solidity for the smart contracts and uses TailwindCSS and Svelte for the frontend. The repository is separated into two main directories: `contracts` and `frontend`.

## Getting Started

To get started with CoinFarm, the following steps should be taken:

1. Clone the repository to the local machine.
2. Install the necessary dependencies.
3. Compile and deploy the smart contracts.
4. Run a local development server for the frontend.

### Prerequisites

Before beginning, the following tools should be installed:

- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/)
- [Foundry toolkit](https://getfoundry.sh/)
### Installation

1. Clone the repository:

```bash
git clone https://github.com/your-username/coinfarm.git
```

2. Navigate to the contract's directory:

```bash
cd coinfarm/contracts
```

3. Install the necessary dependencies:
```bash
npm install
```

4. Compile and deploy the smart contracts:
```bash
forge build
forge create reward_token --constructor-args amount name decimals symbol #deploy reward token
forge create stake_token --constructor-args amount name decimals symbol #deploy staking token
forge create FARM --constructor-args rewardAddress stakeAddress admin rewardPerBlock #deploy the farm contract

```

5. Navigate to the frontend diretory:
```bash
cd ../frontend
```
6. Install the dependencies
```bash
npm install
```

7. Create a `.env` file in the frontend directory with the appropriate environment variables. The `.env.example` file can be used as a reference.

8. Run a local development server for the frontend:
```bash
npm run dev --app
```

## Usage
To use CoinFarm, follow these steps:

1. Connect an Ethereum wallet to the DAPP.
2. Deposit the staking token into CoinFarm.
3. Begin staking the staking token to earn reward tokens.
4. Withdraw the reward tokens at any time.

## Contributing
Contributions to CoinFarm are welcome! If a bug is found or a new feature is desired, an issue should be opened. If a bug needs to be fixed or a new feature implemented, the repository should be forked and a pull request submitted.