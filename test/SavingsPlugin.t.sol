// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import "forge-std/Test.sol";
import "./mocks/mockSavings.sol";
import {MockERC20} from"./mocks/MockERC20.sol";
import "./mocks/mockAccount.sol";

contract SavingsPluginTest is Test {
    MockERC20 public token;
    MockAccount public account;
    MockSavingsPlugin  public plugin;
    
    address public constant SAVINGS_ACCOUNT = address(0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199);
    address public constant RECIPIENT = address(0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65);
    uint256 public constant ROUND_UP_TO = 1;
    uint256 transferAmount = 15 ;
    function setUp() public {
        token = new MockERC20();
        account = new MockAccount();
        plugin = new MockSavingsPlugin ();


   // 1. Set up automation
        vm.prank(address(account));
        plugin.createAutomation(SAVINGS_ACCOUNT, ROUND_UP_TO);
  
    }
    

    function test_create_automation_savings() public {
        // 1. Set up automation
        vm.prank(address(account));
        plugin.createAutomation(SAVINGS_ACCOUNT, ROUND_UP_TO);
      
        // 2. Check that the automation was created successfully
        (address savingsAccount, uint256 roundUpTo, bool enabled) = plugin.savingsAutomations(address(account));
        assertEq(savingsAccount, SAVINGS_ACCOUNT);
    }

  

    //test for pauseAutomation
    function test_pause_automation() public {
        // 1. Set up automation
        vm.prank(address(account));
        plugin.createAutomation(SAVINGS_ACCOUNT, ROUND_UP_TO);
      
        // 2. Check that the automation was created successfully
        (address savingsAccount, uint256 roundUpTo, bool enabled) = plugin.savingsAutomations(address(account));
        assertEq(savingsAccount, SAVINGS_ACCOUNT);
        assertTrue(enabled);

        // 3. Pause the automation
        vm.prank(address(account));
        plugin.pauseAutomation();

        // 4. Check that the automation is paused
        (savingsAccount, roundUpTo, enabled) = plugin.savingsAutomations(address(account));
        assertTrue(!enabled);
    }
   
    //test for onUninstall
    function test_onUninstall() public {
        // 1. Set up automation
        vm.prank(address(account));
        plugin.createAutomation(SAVINGS_ACCOUNT, ROUND_UP_TO);
      
        // 2. Check that the automation was created successfully
        (address savingsAccount, uint256 roundUpTo, bool enabled) = plugin.savingsAutomations(address(account));
        assertEq(savingsAccount, SAVINGS_ACCOUNT);
        assertTrue(enabled);

        // 3. Uninstall the plugin
        vm.prank(address(account));
        plugin.onUninstall("");

        // 4. Check that the automation is removed
        (savingsAccount, roundUpTo, enabled) = plugin.savingsAutomations(address(account));
        assertEq(savingsAccount, address(0));
    }

//test plugin mmetadata 
function test_plugin_metadata() public {
    // 1. Set up automation
    vm.prank(address(account));
   

    // 3. Check the plugin metadata
    string memory name = plugin.NAME();
    string memory version = plugin.VERSION();
    string memory author = plugin.AUTHOR();
    assertEq(name, "Locker Savings Plugin");
    assertEq(version, "1.0.0");
    assertEq(author, "Locker Team");


}

//test plugin manifest
function test_plugin_manifest() public {
    // 1. Set up automation
    vm.prank(address(account));
   

    // 3. Check the plugin manifest
    PluginManifest memory  dependencies = plugin.pluginManifest();
     // Verify expected execution functions are registered.
    assertEq(dependencies.executionFunctions.length, 2);
    assertEq(dependencies.executionFunctions[0], plugin.createAutomation.selector);
    assertEq(dependencies.executionFunctions[1], plugin.pauseAutomation.selector);


   // Verify the pre-execution hook is bound to `IStandardExecutor.execute`.
    ManifestExecutionHook memory hook = dependencies.executionHooks[0];
    assertEq(hook.executionSelector, IStandardExecutor.execute.selector);
    assertEq(hook.postExecHook.functionId, 0); // Maps to `postExecutionHook`

    assertEq(hook.preExecHook.functionId, 0); // Maps to `preExecutionHook`

      /// Validate security-critical permissions.
    assertTrue(dependencies.permitAnyExternalAddress); // Expected for this plugin.
    assertTrue(dependencies.canSpendNativeToken); // Ensure intentional.
    assertEq(dependencies.permittedExecutionSelectors.length, 0); // No additional permissions.
}

//function to test multiple automations
     function test_multiple_automations() public {
        // 1. Set up automation
        vm.prank(address(account));
        plugin.createAutomation(SAVINGS_ACCOUNT, ROUND_UP_TO);
      
        // 2. Check that the automation was created successfully
        (address savingsAccount, uint256 roundUpTo, bool enabled) = plugin.savingsAutomations(address(account));
        assertEq(savingsAccount, SAVINGS_ACCOUNT);
        assertTrue(enabled);

        // 3. Create another automation
        vm.prank(address(account));
        plugin.createAutomation(RECIPIENT, ROUND_UP_TO);

        // 4. Check that the second automation was created successfully
        (savingsAccount, roundUpTo, enabled) = plugin.savingsAutomations(address(account));
        assertEq(savingsAccount, RECIPIENT);

   }

   //function to test partial roundup
    function test_partial_roundup() public {
          // 1. Set up automation
          vm.prank(address(account));
          plugin.createAutomation(SAVINGS_ACCOUNT, ROUND_UP_TO);
        
          // 2. Check that the automation was created successfully
          (address savingsAccount, uint256 roundUpTo, bool enabled) = plugin.savingsAutomations(address(account));
          assertEq(savingsAccount, SAVINGS_ACCOUNT);
          assertTrue(enabled);
    
          // 3. Transfer tokens to the account
          token.mint(address(account), transferAmount);
    
          // 4. Check the balance of the account
          uint256 balance = token.balanceOf(address(account));
          assertEq(balance, transferAmount);
    
          // 5. Round up the balance to the nearest multiple of ROUND_UP_TO
          uint256 roundedBalance = (balance + ROUND_UP_TO - 1) / ROUND_UP_TO * ROUND_UP_TO;
    
          // 6. Check that the rounded balance is correct
          assertEq(roundedBalance, 15);
     }

}