# Advanced Solidity: Martian Token Crowdsale

![alt=""](images/application-image.png)

## Background

After waiting for years and passing several tests, the Martian Aerospace Agency selected you to become part of the first human colony on Mars. As a prominent fintech professional, they chose you to lead a project developing a monetary system for the new Mars colony. You decided to base this new system on blockchain technology and to define a new cryptocurrency named **KaseiCoin**. (Kasei means Mars in Japanese.)

KaseiCoin will be a fungible token that’s ERC-20 compliant. You’ll launch a crowdsale that will allow people who are moving to Mars to convert their earthling money to KaseiCoin.

### Introduction 
Crowdsale is a base contract for managing a token crowdsale, allowing investors to purchase tokens with ether. This contract implements such functionality in its most fundamental form and can be extended to provide additional functionality and/or custom behavior. 

### Step 1: Create the KaseiCoin Token Contract

ERC20 was used for the basic standard implementation. An 'initialSupply' of KaseiCoin tokens was assigned to the address that deploys the KaseiCoin contract. 

```ruby 
contract KC_Token is ERC20, ERC20Detailed, ERC20Mintable {
    constructor()
        ERC20Detailed("KC_Token", "KCC", 18)
        public
    {
        _mint(msg.sender, 1000000);    
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
    
    ....
    
    MintedCrowdsale()
    Crowdsale(rate, wallet, token)
    CappedCrowdsale(cap)

    public
    {
       
    }
```
![deployer_contract](https://user-images.githubusercontent.com/95597283/170859455-a728df37-2d25-4b7e-b696-60dffb77cc34.png)

### Step 4: Extend the Crowdsale Contract by Using OpenZeppelin

The external interface for crowdsale contracts represents the basic interface for purchasing tokens, and conforms the base architecture for crowdsales. It is not intended to be modified / overridden. The internal interface conforms the extensible and modifiable surface of crowdsales. 

The modifications to the crowdsale contract are discussed below. 

### ERC20Capped

The KaseiCoin crowdsale contract was modified to limit the number of tokens available to investors. The extension that adds a cap to the supply of KaseiCoin tokens is below.

```ruby 
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
```
![crowdsale_capped](https://user-images.githubusercontent.com/95597283/170985365-c816519d-6169-462f-8921-812df5e517b8.png)
