// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


import "./Ownable.sol";


// OAVAXToken with Governance.
contract OAVAXLock is Ownable, ERC20("OAVAX Developer Lock", "OAVAXdl"){


	uint public lastPaymentBlocktime = 0;
	ERC20 public OAVAXToken;
	address public Dev;
	uint public constant weiPerWeek = 55384615384615000000000;

	modifier onlyOnceEveryWeek() { //604800 == 1 week bruh
	    require(lastPaymentBlocktime + 604800 < now, "Not enough time has passed: Payment Declined");
	    _;
	}

	receive() external payable {
	     
	}

	constructor() public {
	    _mint(address(this), 14400000000000000000000000);
	}

	function setOAVAXToken(address _OAVAX) public onlyOwner{
		OAVAXToken = ERC20(_OAVAX);
	}

	function setDev(address _Dev) public onlyOwner{
		Dev = _Dev;
	}

	function payDev() public onlyOnceEveryWeek{
		uint contractBalance = OAVAXToken.balanceOf( address(this)); //get contracts OAVAX balance

		if(contractBalance < weiPerWeek){ // makes sure last transfer will be able to go through
			OAVAXToken.transfer(Dev, contractBalance);
			_burn( address(this), contractBalance);	// burn oLOCK token to match OAVAX balance
		}
		else {
			OAVAXToken.transfer(Dev, weiPerWeek); //send predefined weekly amount to dev as payement
			_burn( address(this), weiPerWeek); // burn oLOCK token to match OAVAX balance
		}
		lastPaymentBlocktime = now;
	}

	function getLastPayment() external view returns(uint){
		return lastPaymentBlocktime;
	}




}