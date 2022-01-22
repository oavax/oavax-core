// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IOAVAXVote.sol";
import "./Ownable.sol";


// OAVAX Token with bridge token logic and non-transferable non-valuable Vote token

//Bridge
// it can only be closed.
// it can only be set once
// Bridge Setter is set during deployement to add bridge address after deployement, //Bridge needs OAVAX to be deployed prior
// then it is set at 0 address to remove the right to change bridge address.
// Dev address can only change itself, and close bridge. has no power over anything.

//OAVAX Token
//Can Only be minted by Masterchef
//Can be burnt
//Is the owner of VoteTokens
//Mints VoteTokens 1:1 OAVAX Tokens


contract OAVAXToken is ERC20("Open AVAX", "OAVAX"), Ownable {
    IOAVAXVote public voteToken;
    address public devAddr;
    address public bridgeAddress;
    bool public bridgeOpen = true;
    bool public bridgeSet = false;

    uint256 public burnCount;


    event Mint(address indexed user, uint amount);
    event BridgeMint(address indexed user, uint amount);
    event BridgeAddressChange(address indexed oldAddr, address indexed newAddr);
    event BridgeClosed(bool isClosed);
    event DevChanged(address indexed oldAddr, address indexed newAddr);
   
    modifier bridgeChecks{
        require(msg.sender == bridgeAddress, "Revert: must be called by bridge.");
        require(bridgeAddress != address(0), 'Revert: Bridge must be set.');
        require(bridgeOpen == true, 'Revert: Bridge must be open.');
        _;
    }

    modifier onlyDev{
        require(msg.sender == devAddr);
        _;
    }

    constructor(IOAVAXVote _voteAddress) public{
        devAddr = msg.sender;
        voteToken = _voteAddress;
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        voteToken.mint(_to, _amount);
        _mint(_to, _amount);
        emit Mint(_to, _amount);
    }

    function bridgeMint(address _to, uint256 _amount) public bridgeChecks {
        voteToken.mint(_to, _amount);
        _mint(_to, _amount);
        emit BridgeMint(_to, _amount);
    }

    function setBridgeAddress(address _bridgeAddress) public onlyDev {
        require(bridgeSet == false, "Can only be set once");
        emit BridgeAddressChange(bridgeAddress,_bridgeAddress);
        bridgeAddress = _bridgeAddress;
        bridgeSet = true;
    }

    function closeBridge() public onlyDev{
        bridgeOpen = false;
        emit BridgeClosed(true);
    }

    function dev(address _dev) public onlyDev{
        emit DevChanged(devAddr,_dev);
        devAddr = _dev;
    }

    function burn(address _account, uint256 _amount) public {
        require(_account == msg.sender, "You can't burn tokens you dont own.");
        _burn(_account, _amount);
        burnCount = burnCount + _amount;
    }
}