// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {e, euint256, ebool} from "@inco/lightning/src/Lib.sol";

contract Richestx {
    using e for *;

    error SomethingWrong();
    error InvalidName();
    error UnauthorizedCallback();
    error AlreadyEntered();
    error BalancesNotEntered();
    error NotCompared();

    enum Person { Alice, Bob, Eve }
    enum State { NotEntered, Entered, Compared }

    struct Entry {
        euint256 balance;
        ebool isMax;
        address by;
        uint256 decryptedIsMax;
    }

    mapping(Person => Entry) internal entries;
    address public immutable OWNER;
    State public currentState;

    constructor() {
        OWNER = msg.sender;
        currentState = State.NotEntered;
    }

    modifier onlyOwner() {
        require(msg.sender == OWNER, "Not owner");
        _;
    }

    modifier onlyAuthorized() {
        if (!_isAuthorized(msg.sender)) revert UnauthorizedCallback();
        _;
    }


    function _isAuthorized(address user) internal view returns (bool) {
        for (uint8 i = 0; i < 3; i++) {
            Person person = Person(i);
            if (user == entries[person].by && e.isAllowed(user, entries[person].balance)) {
                return true;
            }
        }
        return false;
    }

    function enterBalance(bytes memory value, string calldata name) external {
        Person person = _getPerson(name);
        if (entries[person].by != address(0)) revert AlreadyEntered();

        entries[person].balance = value.newEuint256(msg.sender);
        entries[person].by = msg.sender;
        entries[person].balance.allowThis();
        entries[person].balance.allow(msg.sender);

        if (
            entries[Person.Alice].by != address(0) &&
            entries[Person.Bob].by != address(0) &&
            entries[Person.Eve].by != address(0)
        ) {
            currentState = State.Entered;
        }
    }

    function compare() external onlyAuthorized {
        if (currentState == State.NotEntered) revert BalancesNotEntered();

        euint256 richest = entries[Person.Alice].balance
            .max(entries[Person.Bob].balance)
            .max(entries[Person.Eve].balance);
        richest.allowThis();

        for (uint8 i = 0; i < 3; i++) {
            Person person = Person(i);
            entries[person].isMax = richest.eq(entries[person].balance);
            entries[person].isMax.allowThis();
            entries[person].isMax.allow(entries[person].by);
            _decryptMaxFlag(person, entries[person].isMax);
        }

        currentState = State.Compared;
    }

    function output() external view returns (string memory) {
        if (currentState != State.Compared) revert NotCompared();

        bytes memory names;
        uint256 winnerCount;

        for (uint8 i = 0; i < 3; i++) {
            Person person = Person(i);
            if (entries[person].decryptedIsMax != 0) {
                if (winnerCount > 0) names = abi.encodePacked(names, " & ");
                names = abi.encodePacked(names, _getPersonName(person));
                winnerCount++;
            }
        }

        if (winnerCount == 0) revert SomethingWrong();

        return string(abi.encodePacked(names, winnerCount > 1 ? " are the richest" : " is the richest"));
    }

    function _decryptMaxFlag(Person person, ebool isMax) internal {
        e.requestDecryption(
            isMax,
            this.onDecryptionCallback.selector,
            abi.encode(person)
        );
    }

    function onDecryptionCallback(
        uint256 requestId,
        bytes32 result,
        bytes memory data
    ) external returns (bool) {
        Person person = abi.decode(data, (Person));
        entries[person].decryptedIsMax = uint256(result);
        return true;
    }

    function _getPerson(string memory name) internal pure returns (Person) {
        bytes32 hashed = keccak256(abi.encodePacked(name));
        if (hashed == keccak256(abi.encodePacked("Alice"))) return Person.Alice;
        if (hashed == keccak256(abi.encodePacked("Bob"))) return Person.Bob;
        if (hashed == keccak256(abi.encodePacked("Eve"))) return Person.Eve;
        revert InvalidName();
    }

    function _getPersonName(Person person) internal pure returns (string memory) {
        if (person == Person.Alice) return "Alice";
        if (person == Person.Bob) return "Bob";
        return "Eve";
    }

    function getBalance(string calldata name) external view returns (euint256) {
        return entries[_getPerson(name)].balance;
    }

    function getBy(string calldata name) external view returns (address) {
        return entries[_getPerson(name)].by;
    }
}
