// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IPluginExecutor} from "../../src/interfaces/IPluginExecutor.sol";

contract MockAccount is IPluginExecutor {
    event ExecutedFromPlugin(address indexed target, uint256 value, bytes data);

    // Helper function to simulate a regular execution call
    function execute(
        address target,
        uint256 value,
        bytes calldata data
    ) external payable {
        (bool success, ) = target.call{value: value}(data);
        require(success, "MockAccount: Execution failed");
    }
  function executeFromPlugin(bytes calldata data) external payable override returns (bytes memory) {
        (bool success, bytes memory result) = address(this).call(data);
        require(success, "MockAccount: Execution failed");
        return result;
    }

    function executeFromPluginExternal(
        address target,
        uint256 value,
        bytes calldata data
    ) external payable override returns (bytes memory) {
        (bool success, bytes memory result) = target.call{value: value}(data);
        require(success, "MockAccount: Execution failed");
        return result;
    }

}