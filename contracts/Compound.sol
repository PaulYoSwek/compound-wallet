pragma solidity ^0.8.19;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './CTokenInterface.sol';
import './CEthInterface.sol';
import './ComptrollerInterface.sol';

contract Compound {
  ComptrollerInterface public comptroller;
  CEthInterface public cEth;

  constructor(
    address _comptroller,
    address _cEthAddress
  ) {
    comptroller = ComptrollerInterface(_comptroller);
    cEth = CEthInterface(_cEthAddress);
  }

//Lending supply
  function supply(address cTokenAddress, uint underlyingAmount) internal {
    CTokenInterface cToken = CTokenInterface(cTokenAddress);
    address underlyingAddress = cToken.underlying(); 
    IERC20(underlyingAddress).approve(cTokenAddress, underlyingAmount);
    uint result = cToken.mint(underlyingAmount);
    require(
      result == 0, 
      'cToken#mint() failed. see Compound ErrorReporter.sol for details'
    );
  }

  function supplyEth(uint underlyingAmount) internal {
    cEth.mint{value: underlyingAmount}();
  }

//Redeem cTooen
  function redeem(address cTokenAddress, uint underlyingAmount) internal {
    CTokenInterface cToken = CTokenInterface(cTokenAddress);
    uint result = cToken.redeemUnderlying(underlyingAmount);
    require(
      result == 0,
      'cToken#redeemUnderlying() failed. see Compound ErrorReporter.sol for more details'
    );
  }

//Redeem ether
  function redeemEth(uint underlyingAmount) internal {
    uint result = cEth.redeemUnderlying(underlyingAmount);
    require(
      result == 0,
      'cEth#redeemUnderlying() failed. see Compound ErrorReporter.sol for more details'
    );
  }

  function claimComp() internal {
    comptroller.claimComp(address(this));
  }

  function getCompAddress() internal view returns(address) {
    return comptroller.getCompAddress();
  }

  function getUnderlyingAddress(
    address cTokenAddress
  ) 
    internal 
    view 
    returns(address) 
  {
    return CTokenInterface(cTokenAddress).underlying();
  }

  function getcTokenBalance(address cTokenAddress) public view returns(uint){
    return CTokenInterface(cTokenAddress).balanceOf(address(this));
  }

  function getUnderlyingBalance(address cTokenAddress) public returns(uint){
    return CTokenInterface(cTokenAddress).balanceOfUnderlying(address(this));
  }

  function getUnderlyingEthBalance() public returns(uint){
    return cEth.balanceOfUnderlying(address(this));
  }
}