pragma solidity ^0.5.12;

import './MultiTimedTokenStaking.sol';

/*
* This is a controller & Factory illustrating how to use a staking contract as an
* ETF managed by decentralized underwriters.
*/

struct ETF {
  string name;
  address staking_addr;
  address issuer;
  uint256 price;
  uint256 units;
  address units_addr;
}

contract UnderwrittenETFController {
  address owner;
  mapping (address=>ETF) registry;

  constructor() {
    owner = msg.sender;
  }

  function __determineCurrentPrice(_asset) returns (uint256){

  }

  function rebalanceETF() {

  }

  function createETF(string memory _name, address[] memory _assets, uint256[] memory _initialDistribution) public {
    uint256 price = __determineCurrentPrice(_assets, _initialDistribution);

    address NewTimedStaker = new MultiTimedTokenStaking(_assets);

    ETF NewETF = ETF(_name, NewTimedStaker, msg.sender, );
    registry[msg.sender] = NewETF;
  }
}
