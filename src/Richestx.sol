// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {e, euint256, ebool} from "@inco/lightning/src/Lib.sol";

/// @title Richestx - A privacy-preserving contract to find the richest among Alice, Bob, and Eve.
/// @author Rajat
/// @notice This contract lets three users enter encrypted balances and compares them to find the richest.
/// @dev Uses Inco's encrypted data types and decryption callbacks for privacy.

contract Richestx {
    using e for *;

    //////// Errors ////////

    error SomethingWrong();
    error InvalidName();
    error UnauthorizedCallback();
    error AlreadyEntered();
    error BalancesNotEntered();
    error NotCompared();

    //////// Enums ////////

    enum Person { Alice, Bob, Eve }
    enum State { NotEntered, Entered, Compared }

    //////// Structs ////////

    struct Entry {
        euint256 balance;
        ebool isMax;
        address by;
        uint256 decryptedIsMax;
    }

    //////// State Variables ////////

    mapping(Person => Entry) internal entries;
    State public currentState;

    //////// Constructor ////////

    /// @notice Initializes the contract with default state.
    constructor() {
        currentState = State.NotEntered;
    }

    //////// Modifiers ////////

    /// @dev Ensures only users who submitted encrypted balances and are authorized can perform certain actions.
    modifier onlyAuthorized() {
        if (!_isAuthorized(msg.sender)) revert UnauthorizedCallback();
        _;
    }

    //////// Internal Functions ////////

    /// @notice Checks if the user is authorized to interact with protected functions.
    /// @param user The address of the user.
    /// @return True if authorized, false otherwise.
    function _isAuthorized(address user) internal view returns (bool) {
        for (uint8 i = 0; i < 3; i++) {
            Person person = Person(i);
            if (user == entries[person].by && e.isAllowed(user, entries[person].balance)) {
                return true;
            }
        }
        return false;
    }

    /// @dev Internal function to initiate decryption request for a person's isMax value.
    /// @param person The person (Alice, Bob, or Eve).
    /// @param isMax The encrypted boolean flag.
    function _decryptMaxFlag(Person person, ebool isMax) internal {
        e.requestDecryption(
            isMax,
            this.onDecryptionCallback.selector,
            abi.encode(person)
        );
    }

    /// @dev Converts a string name to the corresponding Person enum value.
    /// @param name The name ("Alice", "Bob", or "Eve").
    /// @return The corresponding Person enum.
    function _getPerson(string memory name) internal pure returns (Person) {
        bytes32 hashed = keccak256(abi.encodePacked(name));
        if (hashed == keccak256(abi.encodePacked("Alice"))) return Person.Alice;
        if (hashed == keccak256(abi.encodePacked("Bob"))) return Person.Bob;
        if (hashed == keccak256(abi.encodePacked("Eve"))) return Person.Eve;
        revert InvalidName();
    }

    /// @dev Converts a Person enum to its string name.
    /// @param person The Person enum.
    /// @return The corresponding name.
    function _getPersonName(Person person) internal pure returns (string memory) {
        if (person == Person.Alice) return "Alice";
        if (person == Person.Bob) return "Bob";
        return "Eve";
    }

    //////// External Functions ////////

    /// @notice Allows a user to submit an encrypted balance for a specific person.
    /// @param value The encrypted balance.
    /// @param name The name of the person ("Alice", "Bob", or "Eve").
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

    /// @notice Compares the encrypted balances and flags the richest using encrypted logic.
    /// @dev Only callable after all three balances are submitted and by authorized users.
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

    /// @notice Decryption callback handler. Receives the result and stores it.
    /// @param requestId The ID of the decryption request.
    /// @param result The decrypted value as bytes32.
    /// @param data Additional data (encoded Person).
    /// @return True on success.
    function onDecryptionCallback(
        uint256 requestId,
        bytes32 result,
        bytes memory data
    ) external returns (bool) {
        Person person = abi.decode(data, (Person));
        entries[person].decryptedIsMax = uint256(result);
        return true;
    }

    /// @notice Returns the name(s) of the richest participant(s) after decryption.
    /// @return A string with the name(s) of the richest person/people.
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

    /// @notice Returns the encrypted balance of a person.
    /// @param name The name ("Alice", "Bob", or "Eve").
    /// @return The euint256 encrypted balance.
    function getBalance(string calldata name) external view returns (euint256) {
        return entries[_getPerson(name)].balance;
    }

    /// @notice Returns the address of the user who submitted the balance.
    /// @param name The name ("Alice", "Bob", or "Eve").
    /// @return The address that submitted the balance.
    function getBy(string calldata name) external view returns (address) {
        return entries[_getPerson(name)].by;
    }
}
