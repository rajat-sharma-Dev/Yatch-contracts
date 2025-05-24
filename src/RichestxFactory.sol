// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./Richestx.sol";

contract RichestxFactory {
    address public immutable factoryOwner;
    address[] public deployedContracts;

    event ContractDeployed(address indexed creator, address contractAddress);

    constructor() {
        factoryOwner = msg.sender;
    }

    /// @notice Deploy a new Richestx contract and store its address
    function createRichestx() external returns (address) {
        Richestx newContract = new Richestx();
        deployedContracts.push(address(newContract));
        emit ContractDeployed(msg.sender, address(newContract));
        return address(newContract);
    }

    /// @notice Returns the list of all deployed Richestx contract addresses
    function getDeployedContracts() external view returns (address[] memory) {
        return deployedContracts;
    }

    /// @notice Returns the count of deployed contracts
    function getDeployedContractsCount() external view returns (uint256) {
        return deployedContracts.length;
    }

    /// @notice Returns deployed contract at a specific index
    function getDeployedContractAt(uint256 index) external view returns (address) {
        require(index < deployedContracts.length, "Index out of bounds");
        return deployedContracts[index];
    }
}
