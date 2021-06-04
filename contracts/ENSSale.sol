// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'ens-contracts/contracts/registry/ENS.sol';
import 'ens-contracts/contracts/resolvers/Resolver.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ENSSale is Ownable {
    uint256 public price;
    address payable public holder;
    bytes32 public immutable ensNode;
    ENS public immutable ens;
    IERC20 public immutable token;

    constructor(address tokenAddress, address ensAddress, uint256 minPrice, bytes32 _ensNode)
    {
        ens = ENS(ensAddress);
        token = IERC20(tokenAddress);
        price = minPrice;
        ensNode = _ensNode;
    }

    function buy(uint256 amount, address newAddress)
    public
    payable
    {
        require(amount > price, "Insufficient funds");
        require(msg.sender != holder, "Already owned");
        token.transferFrom(msg.sender, address(this), amount);
        if(holder != address(0)) {
            token.transferFrom(address(this), address(holder), price);
        }
        price = amount;
        Resolver r = Resolver(ens.resolver(ensNode));
        r.setAddr(ensNode, newAddress);
    }

    function revoke(address newAddress)
    onlyOwner
    public
    {
        Resolver r = Resolver(ens.resolver(ensNode));
        r.setAddr(ensNode, newAddress);
    }
}
