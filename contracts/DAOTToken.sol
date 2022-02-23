// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./RecoverableFunds.sol";

contract DAOTToken is ERC20Burnable, RecoverableFunds {
    constructor() payable ERC20("DAO TOOLS", "DAOT") {
        _mint(_msgSender(), 500_000_000 ether);
    }
}
