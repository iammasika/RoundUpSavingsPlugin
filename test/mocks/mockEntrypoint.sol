//mock entrypoint contract

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "../../lib/reference-implementation/lib/account-abstraction/contracts/core/EntryPoint.sol";
contract MockEntryPoint is EntryPoint {

constructor() EntryPoint() {
    // Constructor logic if needed
}

}