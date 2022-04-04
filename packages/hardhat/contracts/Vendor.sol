pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    uint256 amount = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amount);

    emit BuyTokens(msg.sender, msg.value, amount);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner {
    uint256 amount = address(this).balance;
    require(amount > 0, "Not enough Ether available");
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Failed to withdraw Eth");
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 amount) public {
    uint256 eth = amount / tokensPerEth;

    yourToken.transferFrom(msg.sender, address(this), amount);
    (bool sent, ) = msg.sender.call{value: eth }("");
    require(sent, "Failed to transfer Eth");

    emit SellTokens(msg.sender, amount, eth);
  }

}
