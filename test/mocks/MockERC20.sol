//generate a mock ERC20 token contract
pragma solidity ^0.8.0;

import  "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
  
      constructor() ERC20("Mock Token", "MTK") {
       
   }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    
}