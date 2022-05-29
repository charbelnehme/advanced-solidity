pragma solidity ^0.5.5;

import "./KaseiCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/AllowanceCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";

// Crowdsale token contract 
contract KC_TokenCrowdsale is Crowdsale, MintedCrowdsale { 
    constructor(
        uint256 rate, 
        address payable wallet,
        KC_Token token
    )

    MintedCrowdsale()
    Crowdsale(rate, wallet, token)
    public
    {
        //. Leave empty
    }

}

// Crowdsale deployer contract
contract KC_TokenCrowdsaleDeployer {
    address public kc_token_address;
    address public kc_crowdsale_address; 

    constructor(
        string memory name,
        string memory symbol, 
        address payable wallet
    )
    public
    {
        // Create a mintable token 
        KC_Token token = new KC_Token(name, symbol, 0);
        kc_token_address = address(token);

        // Create the crowdsale and tell it about the token 
        KC_TokenCrowdsale crowdsale = new KC_TokenCrowdsale(
            1,          // Rate
            wallet, // Send KC tokens to the deployer 
            token       // KaseiCoin token
        );
        kc_crowdsale_address = address(kc_token_address);

        // Transfer the minter role from this contract to the crowdsale 
        token.addMinter(kc_crowdsale_address); 
        token.renounceMinter(); 

    }
}

// Allowance contract
contract KC_TokenAllowance is Crowdsale, AllowanceCrowdsale {
    address public token_address;
    address public crowdsale_address; 

    constructor(
        uint256 rate,
        address payable wallet,
        KC_Token token,
        address KC_TokenWallet  
    )
        AllowanceCrowdsale(KC_TokenWallet)  
        Crowdsale(rate, wallet, token)
        public
    {
         KC_Token(token_address).approve(crowdsale_address, 100000);  // Approve tokens for crowdsale
    }
}

// Capped crowdsale 
contract KC_TokenCrowdsaleCapped is Crowdsale, MintedCrowdsale, CappedCrowdsale{
	uint256 public investorMinCap = 10000000000000;
	uint256 public investorHardCap = 10000000000000000000;
	mapping(address => uint256) public contributions;

	constructor(
        uint256 rate,
	    address payable wallet,
	    KC_Token token,
	    uint256 cap
    )
        Crowdsale(rate, wallet, token)
	    CappedCrowdsale(cap)
	    public
    {
        //. Leave empty
	}
    
    function preValidatePurchase(
        address beneficiary,
        uint256 weiAmount
    )
    
    internal{
        super._preValidatePurchase(beneficiary, weiAmount);
        uint256 existingContribution = contributions[beneficiary];
        uint256 newContribution = existingContribution.add(weiAmount);
        require(newContribution >= investorMinCap && newContribution <= investorHardCap);
	    contributions[beneficiary] = newContribution;     
        }
}