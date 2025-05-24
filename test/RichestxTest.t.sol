// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IncoTest} from "@inco/lightning/src/test/IncoTest.sol";
import {Richestx} from "../src/Richestx.sol";

contract RichestxTest is IncoTest {
    Richestx richest;

    bytes value1;
    bytes value2;
    bytes value3;

    function setUp() public override {
        super.setUp();
        richest = new Richestx();

        value1 = fakePrepareEuint256Ciphertext(1 ether);
        value2 = fakePrepareEuint256Ciphertext(2 ether);
        value3 = fakePrepareEuint256Ciphertext(3 ether);
    }

    function testEnterBalance() public {
        vm.startPrank(address(1));
        richest.enterBalance(value1, "Alice");
        vm.stopPrank();

        vm.startPrank(address(2));
        richest.enterBalance(value2, "Bob");
        vm.stopPrank();

        vm.startPrank(address(3));
        richest.enterBalance(value3, "Eve");
        vm.stopPrank();

        processAllOperations();

        assertEq(getUint256Value(richest.getBalance("Alice")), 1 ether);
        assertEq(getUint256Value(richest.getBalance("Bob")), 2 ether);
        assertEq(getUint256Value(richest.getBalance("Eve")), 3 ether);
    }

    function testCompare() public {
        vm.startPrank(address(1));
        richest.enterBalance(value1, "Alice");
        vm.stopPrank();

        vm.startPrank(address(2));
        richest.enterBalance(value2, "Bob");
        vm.stopPrank();

        vm.startPrank(address(3));
        richest.enterBalance(value3, "Eve");
        vm.stopPrank();

        vm.startPrank(address(3));
        richest.compare();
        vm.stopPrank();

        processAllOperations();

        string memory result = richest.output();
        assertEq(result, "Eve is the richest");
    }

    function testDoubleEntryReverts() public {
        vm.startPrank(address(1));
        richest.enterBalance(value1, "Alice");
        vm.expectRevert("AlreadyEntered()");
        richest.enterBalance(value2, "Alice");
        vm.stopPrank();
    }

    function testUnauthorizedCompareFails() public {
        vm.startPrank(address(1));
        richest.enterBalance(value1, "Alice");
        vm.stopPrank();

        vm.startPrank(address(2));
        richest.enterBalance(value2, "Bob");
        vm.stopPrank();

        vm.startPrank(address(3));
        richest.enterBalance(value3, "Eve");
        vm.stopPrank();

        vm.startPrank(address(4));
        vm.expectRevert("UnauthorizedCallback()");
        richest.compare();
        vm.stopPrank();
    }

    function testCompareFailsIfNotAllEntered() public {
        vm.startPrank(address(1));
        richest.enterBalance(value1, "Alice");
        vm.stopPrank();

        vm.startPrank(address(2));
        richest.enterBalance(value2, "Bob");
        vm.stopPrank();

        vm.startPrank(address(1));
        vm.expectRevert("BalancesNotEntered()");
        richest.compare();
        vm.stopPrank();
    }

    function testOutputFailsIfNotCompared() public {
        vm.startPrank(address(1));
        richest.enterBalance(value1, "Alice");
        vm.stopPrank();

        vm.startPrank(address(2));
        richest.enterBalance(value2, "Bob");
        vm.stopPrank();

        vm.startPrank(address(3));
        richest.enterBalance(value3, "Eve");
        vm.stopPrank();

        vm.expectRevert("NotCompared()");
        richest.output();
    }

    function testOutputWithTie() public {
        value1 = fakePrepareEuint256Ciphertext(3 ether);
        value2 = fakePrepareEuint256Ciphertext(3 ether);
        value3 = fakePrepareEuint256Ciphertext(1 ether);

        vm.startPrank(address(1));
        richest.enterBalance(value1, "Alice");
        vm.stopPrank();

        vm.startPrank(address(2));
        richest.enterBalance(value2, "Bob");
        vm.stopPrank();

        vm.startPrank(address(3));
        richest.enterBalance(value3, "Eve");
        vm.stopPrank();

        vm.startPrank(address(1));
        richest.compare();
        vm.stopPrank();

        processAllOperations();

        string memory result = richest.output();
        assertEq(result, "Alice & Bob are the richest");
    }

    function testInvalidNameReverts() public {
        vm.expectRevert("InvalidName()");
        richest.enterBalance(value1, "John");
    }

    function testFuzzInvalidNameReverts(bytes memory value, string calldata name) public {
    vm.assume(
        keccak256(abi.encodePacked(name)) != keccak256("Alice") &&
        keccak256(abi.encodePacked(name)) != keccak256("Bob") &&
        keccak256(abi.encodePacked(name)) != keccak256("Eve")
    );

    vm.expectRevert(Richestx.InvalidName.selector);
    richest.enterBalance(value, name);
    }

    function testFuzzRichestDetection(
    uint256 aVal,
    uint256 bVal,
    uint256 eVal
) public {
    
    vm.assume(aVal != bVal && bVal != eVal && aVal != eVal);
    vm.assume(aVal < 100 ether && bVal < 100 ether && eVal < 100 ether);

    value1 = fakePrepareEuint256Ciphertext(aVal);
    value2 = fakePrepareEuint256Ciphertext(bVal);
    value3 = fakePrepareEuint256Ciphertext(eVal);

    vm.prank(address(1));
    richest.enterBalance(value1, "Alice");

    vm.prank(address(2));
    richest.enterBalance(value2, "Bob");

    vm.prank(address(3));
    richest.enterBalance(value3, "Eve");

    vm.prank(address(1)); 
    richest.compare();

    processAllOperations();

    string memory result = richest.output();

    if (aVal > bVal && aVal > eVal) {
        assertEq(result, "Alice is the richest");
    } else if (bVal > aVal && bVal > eVal) {
        assertEq(result, "Bob is the richest");
    } else if (eVal > aVal && eVal > bVal) {
        assertEq(result, "Eve is the richest");
    }
}

function testFuzzDoubleEntryReverts(bytes calldata val1, bytes calldata val2) public {
    vm.prank(address(1));
    richest.enterBalance(val1, "Alice");

    vm.prank(address(2));
    vm.expectRevert(Richestx.AlreadyEntered.selector);
    richest.enterBalance(val2, "Alice");
}

function testFuzzCompareFailsIfNotAllEntered(bytes calldata val1, bytes calldata val2) public {
    vm.prank(address(1));
    richest.enterBalance(val1, "Alice");

    vm.prank(address(2));
    richest.enterBalance(val2, "Bob");

    vm.prank(address(1));
    vm.expectRevert(Richestx.BalancesNotEntered.selector);
    richest.compare();
}




function testFuzzExtremeValues(uint256 aVal, uint256 bVal, uint256 eVal) public {
    vm.assume(aVal <= 1e40 && bVal <= 1e40 && eVal <= 1e40); 
    value1 = fakePrepareEuint256Ciphertext(aVal);
    value2 = fakePrepareEuint256Ciphertext(bVal);
    value3 = fakePrepareEuint256Ciphertext(eVal);

    vm.prank(address(1));
    richest.enterBalance(value1, "Alice");

    vm.prank(address(2));
    richest.enterBalance(value2, "Bob");

    vm.prank(address(3));
    richest.enterBalance(value3, "Eve");

    vm.prank(address(2));
    richest.compare();

    processAllOperations();

    string memory result = richest.output();

    if (aVal > bVal && aVal > eVal) {
        assertEq(result, "Alice is the richest");
    } else if (bVal > aVal && bVal > eVal) {
        assertEq(result, "Bob is the richest");
    } else if (eVal > aVal && eVal > bVal) {
        assertEq(result, "Eve is the richest");
    }
}

}
