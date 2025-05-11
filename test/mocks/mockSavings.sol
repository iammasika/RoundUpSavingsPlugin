// mock the saving plugin
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;
import "../../src/plugins/savings/SavingsPlugin.sol";

contract MockSavingsPlugin is SavingsPlugin {
constructor() SavingsPlugin() {
    // Constructor logic if needed
}

}