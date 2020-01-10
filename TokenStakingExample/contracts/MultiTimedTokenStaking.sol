pragma solidity ^0.5.12;

import "./interfaces/IStaking.sol";
import "./math/SafeMath.sol";
import "./token/IERC20.sol";

/*
* This is a contract implementing the draft specification of EIP-900;
*/


contract MultiTimedTokenStaking is IStaking {

  using SafeMath for uint256;

  uint256 lockup = 21 days; // Spin out into Variable & Constructor
  uint256 __totalStaked;
  bool __supportsHistory = false;

  struct Stake {
    uint256 amount;
    bytes data;
    uint256 stakedOn;
    uint256 canUnstakeAfter;
  }


  mapping(address => mapping(address => Stake)) stakes; // token_address => stakers => Stake
  mapping(uint256 => address) tokens; // For example purposes this would be a numerical id

  event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
  event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);


  modifier MustBeAllowed(uint256 _token_idx, address _sender, address _deligate, uint256 _amount) {
    require(IERC20(tokens[_token_idx]).allowance(_sender, _deligate) >= _amount, "This account lacks needed asset.");
    _;
  }


  constructor (address[] memory _tokens) public {
    for (uint i=0; i < _tokens.length; i++) {
      tokens[i] = _tokens[i];
    }
  }


  /*
  * Internal Function for transferring tokens for staking.
  *
  * @remark Possibly spin this into the controller but for development, keep here
  * for convenience
  */

  function __transferToken(address _token_addr, address _sender, address _recipient, uint256 _amount) private {
    // Allowance must be set
    IERC20 token = IERC20(_token_addr);
    token.transferFrom(_sender, _recipient, _amount);
  }

  /*
  * Stakes a certain amount of tokens, this MUST transfer the given amount from the user.
  */

  function stake(uint256 amount, bytes memory data, uint256 _token_idx) public MustBeAllowed(_token_idx, msg.sender, address(this), amount){
    __transferToken(tokens[_token_idx], msg.sender, address(this), amount);
    stakes[tokens[_token_idx]][msg.sender] = Stake(amount, data, block.timestamp, block.timestamp.add(lockup));
    __totalStaked.add(amount);
    emit Staked(msg.sender, amount, __totalStaked, data);
  }

  /*
  * Stakes on behalf of another a certain amount of tokens, this MUST transfer the given amount from the caller.
  */

  function stakeFor(address user, uint256 amount,  bytes memory data, uint256 _token_idx) public MustBeAllowed(_token_idx, msg.sender, address(this), amount){
    __transferToken(tokens[_token_idx], msg.sender, address(this), amount);
    stakes[tokens[_token_idx]][user] = Stake(amount, data, block.timestamp, block.timestamp.add(lockup));
    __totalStaked.add(amount);
    emit Staked(user, amount, __totalStaked, data);
  }

  /*
  * Unstakes a certain amount of tokens, this SHOULD return the given amount of
  * tokens to the user, if unstaking is currently not possible the function MUST revert.
  */

  function unstake(uint256 amount, bytes memory data, uint256 _token_idx) public {
    require(block.timestamp > stakes[tokens[_token_idx]][msg.sender].canUnstakeAfter, "Cannot Unstake Yet.");
    __transferToken(tokens[_token_idx], address(this), msg.sender, amount);
    __totalStaked.sub(amount);
    emit Unstaked(msg.sender, amount, __totalStaked, data);
  }

  /*
   * Returns the current total of tokens staked for an address.
   */

  function __totalStakedFor(address addr, uint256 token_idx) public view returns (uint256) {
    return stakes[tokens[token_idx]][addr].amount;
  }

  /*
  * Returns the current total of tokens staked.
  */

  function totalStaked() public view returns (uint256) {
    return __totalStaked;
  }


  /*
  * Address of the token being used by the staking interface.
  */
  function token(uint256 _token_idx) public view returns (address) {
    return tokens[_token_idx];
  }

  /*
  * MUST return true if the optional history functions are implemented, otherwise false.
  * @to-do implement history support
  */

  function supportsHistory() public pure returns (bool) {
    return __supportsHistory;
  }

  /*
  * Returns last block address staked at.
  * @to-do implement history support
  */

  function lastStakedFor(address addr) public view returns (uint256) {

  }

  /*
  * Returns total amount of tokens staked at block for address.
  * @to-do implement history support
  */

  function __totalStakedForAt(address addr, uint256 blockNumber) public view returns (uint256) {

  }


  /*
  * Returns the total tokens staked at block.
  * @to-do implement history support
  */
  function __totalStakedAt(uint256 blockNumber) public view returns (uint256) {

  }



}
