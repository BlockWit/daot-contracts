// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IVestingWallet.sol";
import "./RecoverableFunds.sol";
import "./interfaces/ICrowdSale.sol";
import "./interfaces/ITokenDepositor.sol";

contract Configurator is RecoverableFunds {

    IERC20 public token;
    ICrowdSale public sale;
    IVestingWallet public wallet;
    ITokenDepositor public depositor;

    function init(address _token, address _wallet, address _sale, address _depositor) public onlyOwner {
        token = IERC20(_token);
        sale = ICrowdSale(_sale);
        wallet = IVestingWallet(_wallet);
        depositor = ITokenDepositor(_depositor);
    }

}
