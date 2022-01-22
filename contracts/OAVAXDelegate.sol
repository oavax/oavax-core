// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./uniswapv2/interfaces/IUniswapV2ERC20.sol";
import "./uniswapv2/interfaces/IUniswapV2Pair.sol";
import "./uniswapv2/interfaces/IUniswapV2Factory.sol";

contract OAVAXDelegate is Ownable{
	using SafeMath for uint256;
	mapping(address => delegatorData) public delegatorStats;
	address private multiTransfer;
	address public bbusd = 0x19860CCB0A68fd4213aB9D8266F7bBf05A8dDe98;
	address public oavax = 0xd87458dd27A1D3C47Fe620D05668169e5a85B064;
	address public wavax = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;

	IUniswapV2Factory public immutable factory = IUniswapV2Factory(0x161FdbA801F1cC81DcB9f4e90c9f06E5317d3D7d);

	struct delegatorData {
	   address delegatorAddr;
	   uint256 avaxStaked;
	   uint256 oxratio;
	   uint256 earnedAVAX;
	   uint256 earnedOAVAX;
	   uint256 earnedUSD;
	}

	modifier onlyMultiTransfer{
		require(msg.sender == multiTransfer, "Non.");
		 _;
	}

	function setMultiTransfer(address _contract) public onlyOwner{
		multiTransfer = _contract;
	}

	function setRatioPercentageOAVAX(uint256 _ratio) public {
		require(_ratio >= 30, "Minimum must be 30% OAVAX...");
		require(_ratio <= 100, "Only up to 100%. Love, dev.");
		delegatorData storage del = delegatorStats[tx.origin];

		del.oxratio = _ratio;
	}
	function getRatio(address _user) public view returns(uint256){
		delegatorData storage del = delegatorStats[_user];
		if(del.oxratio == 0)
		{
			return uint256(100);
		}
		else{
			return del.oxratio;
		}	
	}


	function logUser(address userAddr,uint256 stakedAmount,uint256 oavaxAmount,uint256 avaxAmount) public onlyMultiTransfer {
		delegatorData storage del = delegatorStats[userAddr];
		uint256 usdAVAX;
		if(avaxAmount != 0){
			usdAVAX = valueUSD(wavax, bbusd, avaxAmount);
		}
	
		uint256 usdOAVAX = valueUSD(oavax, bbusd, oavaxAmount);
		del.earnedUSD = del.earnedUSD + usdOAVAX + usdAVAX;

		del.earnedAVAX += avaxAmount;
		del.earnedOAVAX += oavaxAmount;

		if(del.delegatorAddr == address(0)){
			del.delegatorAddr = userAddr;
		}

		if(stakedAmount != del.avaxStaked){
			del.avaxStaked = stakedAmount;
		}


	}
	function valueUSD(address fromToken,address toToken,uint256 amountIn)public returns(uint256){
	// X1 - X5: OK
	uint256 amountOut;
        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(fromToken, toToken));
   
        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
        uint256 amountInWithFee = amountIn.mul(997);

        if (fromToken == pair.token0()) {
         amountOut = amountIn.mul(997).mul(reserve1) / reserve0.mul(1000).add(amountInWithFee);
         } else {
         amountOut = amountIn.mul(997).mul(reserve0) / reserve1.mul(1000).add(amountInWithFee);
         }
      return amountOut;
	}
}