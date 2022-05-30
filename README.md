# Advanced Solidity: Martian Token Crowdsale

![alt=""](images/application-image.png)

## Background

After waiting for years and passing several tests, the Martian Aerospace Agency selected you to become part of the first human colony on Mars. As a prominent fintech professional, they chose you to lead a project developing a monetary system for the new Mars colony. You decided to base this new system on blockchain technology and to define a new cryptocurrency named **KaseiCoin**. (Kasei means Mars in Japanese.)

KaseiCoin will be a fungible token that’s ERC-20 compliant. You’ll launch a crowdsale that will allow people who are moving to Mars to convert their earthling money to KaseiCoin.

### Introduction 
Crowdsale is a base contract for managing a token crowdsale, allowing investors to purchase tokens with ether. This contract implements such functionality in its most fundamental form and can be extended to provide additional functionality and/or custom behavior. 

### Step 1: Create the KaseiCoin Token Contract

```ruby 
contract KC_Token is ERC20, ERC20Detailed, ERC20Mintable {
    constructor(
        string memory name,
        string memory symbol,
        uint initial_supply
    )
        ERC20Detailed("KC_Token", "KCC", 18)
        public
    {
        mint(msg.sender, initial_supply);
    }
}
```

![kc_token_deployed](https://user-images.githubusercontent.com/95597283/170858899-e428e801-0047-4949-aa00-90fddf35f2fd.png)


### Step 2: Create the KaseiCoin Crowdsale Contract

```ruby
contract KaseiCoinCrowdsale is Crowdsale, MintedCrowdsale, CappedCrowdsale { 
    constructor(
        uint256 rate, 
        address payable wallet,
        KaseiCoin token,
        uint256 cap
    )

    MintedCrowdsale()
    Crowdsale(rate, wallet, token)
    CappedCrowdsale(cap)

    public
    {
       //.
    }
```

![crowdsale_contract](https://user-images.githubusercontent.com/95597283/170859454-fd42db5b-9028-416c-b708-be4c6630616f.png)


### Step 3: Create the KaseiCoin Deployer Contract

```ruby
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
        KaseiCoin token, 
        uint256 cap
    )

    MintedCrowdsale()
    Crowdsale(rate, wallet, token)
    CappedCrowdsale(cap)

    public
    {
        // Create a mintable token 
        KaseiCoin token = new KaseiCoin(name, symbol, 0);
        kc_token_address = address(token);

        // Create the crowdsale and tell it about the token
        KaseiCoinCrowdsale crowdsale = new KaseiCoinCrowdsale(1, wallet, token, cap);

        // Send tokens to the deployer
        kc_crowdsale_address = address(kc_token_address);

        // Transfer the minter role from this contract to the crowdsale 
        token.addMinter(kc_crowdsale_address); 
        token.renounceMinter(); 

        // Approve tokens for crowdsale
        KaseiCoin(kc_token_address).approve(kc_crowdsale_address, 100000);
    }
```
![deployer_contract](https://user-images.githubusercontent.com/95597283/170859455-a728df37-2d25-4b7e-b696-60dffb77cc34.png)

### Step 4: Extend the Crowdsale Contract by Using OpenZeppelin

The external interface for crowdsale contracts represents the basic interface for purchasing tokens, and conforms the base architecture for crowdsales. It is not intended to be modified / overridden. The internal interface conforms the extensible and modifiable surface of crowdsales. 

The KaseiCoin crowdsale contract was modified to limit the number of tokens available to investors. The modifications to the crowdsale contract are discussed below. 

#### Capped Crowdsale 

```
> Events

TokensPurchased(purchased, beneficiary, value, amount)

> Constructor

constructor(uint256 cap)

The 'capped crowdsale' constructor takes the maximum amount of wei accepted in the sale. 

_preValidatePurchase(address beneficiary, uint256 weiAmount)

Extend parent behaviour requiring purchase to respect the funding cap.

![crowdsale_capped](https://user-images.githubusercontent.com/95597283/170975766-5bfcd1f2-64ac-4259-a7a5-541c34594438.png)

```

![capped](https://user-images.githubusercontent.com/95597283/170858658-295a5f12-a6b3-4d31-833d-bf3e695d11ec.png)

```ruby
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
```
