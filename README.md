# Millionaire's Dilemma 🧠💸

A privacy-preserving DApp built on the Inco Network that enables secure comparison of encrypted on-chain values — think of it as "Who’s richer?" without revealing actual balances.

---

## 🛠 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/rajat-sharma-Dev/Millionaires-dilemma.git
```

### 2. Navigate into the Project Directory

```bash
cd Millionaires-dilemma
```

### 3. Install Dependencies

```bash
npm install
```

### 4. Run the Project Locally

```bash
npm run dev
```

Your app should now be running on [http://localhost:3000](http://localhost:3000).

---

## 📦 Smart Contracts

The smart contracts powering this DApp are maintained in a separate repository:  
🔗 [Yatch-contracts Repository](https://github.com/rajat-sharma-Dev/Yatch-contracts.git)

Clone them with:

```bash
git clone https://github.com/rajat-sharma-Dev/Yatch-contracts.git
```

---

## 🔐 Key Features

- Encrypted on-chain values using [Inco Network](https://inco.org)
- Secure comparison logic using `euint256` and `ebool`
- Zero-leakage frontend — only authorized users can decrypt/view data
- Real-world privacy use case for Web3 applications

---

## ⚙️ Foundry

[Foundry](https://book.getfoundry.sh/) is a blazing fast, portable, and modular toolkit for Ethereum application development written in Rust. It includes tools for compiling, testing, deploying, and interacting with smart contracts.

### 🧰 Components

- **Forge** – Ethereum testing framework (like Hardhat/Truffle)
- **Cast** – CLI tool for interacting with contracts, sending transactions
- **Anvil** – Local Ethereum node (like Ganache)
- **Chisel** – Solidity REPL for quick prototyping

---

## 📚 Foundry Docs

📖 [https://book.getfoundry.sh](https://book.getfoundry.sh)

---

## 🚀 Foundry Usage

### 🔨 Build Contracts

```bash
forge build
```

### ✅ Run Tests

```bash
forge test
```

### 🧽 Format Code

```bash
forge fmt
```

### ⛽️ Gas Snapshots

```bash
forge snapshot
```

### 🧪 Start Local Node

```bash
anvil
```

### 🚀 Deploy Contracts

Update with your RPC and private key:

```bash
forge script script/Counter.s.sol:CounterScript \
  --rpc-url <YOUR_RPC_URL> \
  --private-key <YOUR_PRIVATE_KEY>
```

### 🛠 Use Cast

```bash
cast <subcommand>
```

---

## 🆘 Help

```bash
forge --help
anvil --help
cast --help
```

---

## 🤝 Contributing

Contributions are welcome!  
Fork the repo, make changes, and open a pull request.  
Please test locally before submitting PRs.

---

## 📄 License

This project is licensed under the **MIT License**.
