// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint256) public balances;

  uint256 public constant threshold = 1 ether;

  event Stake(address by, uint256 amount);

  uint256 public deadline = block.timestamp + 300 seconds;

  bool public openForWithdraw = false;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() public payable {
    balances[msg.sender] += msg.value;

    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  // if the `threshold` was not met, allow everyone to call a `withdraw()` function

  function execute() public {
    if (block.timestamp > deadline) {
      if (address(this).balance > threshold) {
        exampleExternalContract.complete{value: address(this).balance}();    
      } else if (address(this).balance < threshold) {
        openForWithdraw = true;
      }
    }
  }

  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() public {
    if (openForWithdraw) {
      uint256 amount = balances[msg.sender];
      // address(this).balance += amount;
    }
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    }
    return deadline - block.timestamp;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }

  modifier notCompleted() {
    require(exampleExternalContract.completed == false, "Not Completed"); 
    _;
  }
}
