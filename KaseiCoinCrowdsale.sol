pragma solidity ^0.5.5;

import "./KaseiCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/AllowanceCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";

// Crowdsale token contract 
contract KaseiCoinCrowdsale is Crowdsale, MintedCrowdsale, CappedCrowdsale { 
    constructor(
        uint256 rate, 
        address payable wallet,
        KC_Token token,
        uint256 cap
    )

    MintedCrowdsale()
    Crowdsale(rate, wallet, token)
    CappedCrowdsale(cap)

    public
    {
        // Empty
    }

}

// Crowdsale deployer contract
contract KaseiCoinCrowdsaleDeployer is Crowdsale, MintedCrowdsale, CappedCrowdsale {
    address public kc_token_address;
    address public kc_crowdsale_address; 
    uint256 public investorMinCap = 1000000000;
    uint256 public investorHardCap = 1000000000000000;
    mapping(address => uint256) public contributions;

    constructor(
        string memory name,
        string memory symbol, 
        address payable wallet,
        uint256 rate, 
        KC_Token token, 
        uint256 cap
    )

    MintedCrowdsale()
    Crowdsale(rate, wallet, token)
    CappedCrowdsale(cap)

    public
    {
        // Create a mintable token 
        KC_Token token = new KC_Token(name, symbol, 0);
        kc_token_address = address(token);

        // Create the crowdsale and tell it about the token
        KaseiCoinCrowdsale crowdsale = new KaseiCoinCrowdsale(1, wallet, token, cap);
        // Send tokens to the deployer
        kc_crowdsale_address = address(kc_token_address);

        // Transfer the minter role from this contract to the crowdsale 
        token.addMinter(kc_crowdsale_address); 
        token.renounceMinter(); 
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
