// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./RecoverableFunds.sol";

contract ERC20Mock is ERC20, RecoverableFunds {
    constructor() payable ERC20("DAO TOOLS", "DAOT") {
        _mint(_msgSender(), 500_000_000 ether);
    }
}
