// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./OAVAXToken.sol";


contract OAVAXBridge is ReentrancyGuard {
	IERC20 public oavaxV1;
	OAVAXToken public oavaxV2;
	address public burnAddress = 0xdEad000000000000000000000000000000000000;

	constructor(IERC20 _oavaxV1, OAVAXToken _oavaxV2) public {
		oavaxV1 = _oavaxV1;
		oavaxV2 = _oavaxV2;
	}

	event Bridge(address indexed user, uint amount);

	function convert(uint256 _amount) public nonReentrant {
		require(msg.sender == tx.origin, "Must be called directly");

		bool success = false;

		success = oavaxV1.transferFrom(msg.sender, burnAddress, _amount);

		require(success == true, 'transfer failed');

		oavaxV2.bridgeMint(msg.sender, _amount);
		emit Bridge(msg.sender, _amount);
		
	}
}