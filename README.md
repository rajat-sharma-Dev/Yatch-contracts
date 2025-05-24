# 🛥️ Yatch Contracts — Richestx.sol & Privacy-Preserving Logic

This repository contains the smart contracts powering the Millionaire’s Dilemma DApp — built with encrypted logic on the [Inco Network](https://inco.org), enabling on-chain value comparison without leaking any sensitive data.

---

## 🎥 Demo Walkthrough

👉 [Explanation video](https://www.youtube.com/playlist?list=PLkBjK0MLKIF9a7ytWmdZ5l3Dm0akwBCXZ)  
📌 *Recommended speed: 1.5x or 1.7x for a smooth learning experience*

---

## 📁 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/rajat-sharma-Dev/Yatch-contracts.git
```

### 2. Navigate to the Library Directory

```bash
cd Yatch-contracts/lib
```

### 3. Clone the Inco Lightning Library

```bash
git clone https://github.com/inco-network/inco-lightning.git
```

### 4. Modify Inco Version

Go to the `package.json` inside `lib/inco-lightning` and change:

```json
"dependencies": {
  "inco": "1.30.0"
}
```

### 5. Install Dependencies

```bash
npm install
```

---

## 🧪 Compile & Test Contracts

### 6. Compile with Forge

```bash
forge build
```

### 7. Run the Tests

```bash
forge test
```

---

## 🔐 Smart Contracts Overview

- **`Richestx.sol`** — Core contract for encrypted value comparison
- **`RichestxFactory.sol`** — Factory contract for deploying the Richestx.sol

---

## 🔑 Key Concepts

- Built with [Inco Network](https://inco.org) encryption primitives (`euint256`, `ebool`)
- Zero-leakage comparison logic: Only allowed users can decrypt
- No sensitive data revealed in contract storage or event logs
- Real-world use case for privacy-preserving computation on-chain

---

## 🤝 Contributing

Contributions are welcome!





---

## 📄 License

This project is licensed under the MIT License.
