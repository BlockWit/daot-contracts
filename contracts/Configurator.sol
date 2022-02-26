// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IVestingWallet.sol";
import "./RecoverableFunds.sol";
import "./interfaces/ICrowdSale.sol";
import "./interfaces/IOwnable.sol";
import "./interfaces/ITokenDepositor.sol";
import "./VestingWallet.sol";
import "./TokenDepositor.sol";
import "./lib/Stages.sol";

contract Configurator is RecoverableFunds {

    struct Amounts {
        uint256 sale;
        uint256 advisors;
        uint256 airdrop;
        uint256 staking;
        uint256 team;
        uint256 marketing;
        uint256 reserve;
        uint256 liquidity;
    }

    struct Addresses {
        address owner;
        address fundraising;
        address sale;
        address advisors;
        address airdrop;
        address staking;
        address team;
        address marketing;
        address reserve;
        address liquidity;
    }

    IERC20 public token;
    ICrowdSale public sale;
    IVestingWallet public wallet;
    ITokenDepositor public depositor;

    function init(address _token, address _wallet, address _sale, address _depositor) public onlyOwner {

        uint256 BASE_PRICE =            20 ether;           // 0.05 USDT per DAOT

        Stages.Stage[2] memory stages;

        stages[0].start =               1646049600;         // Feb 28 2022 12:00:00 UTC
        stages[0].end =                 1649937600;         // April 14 2022 12:00:00 UTC
        stages[0].bonus =               234;
        stages[0].minInvestmentLimit =  500 ether;
        stages[0].hardcapInTokens =     10_000_000 ether;
        stages[0].vestingSchedule =     1;
        stages[0].unlockedOnTGE =       50;
        stages[0].whitelist =           true;

        stages[1].start =               1646049600;         // Feb 28 2022 12:00:00 UTC
        stages[1].end =                 1649937600;         // April 14 2022 12:00:00 UTC
        stages[1].bonus =               234;
        stages[1].minInvestmentLimit =  500 ether;
        stages[1].hardcapInTokens =     40_000_000 ether;
        stages[1].vestingSchedule =     2;
        stages[1].unlockedOnTGE =       10;
        stages[1].whitelist =           true;

        Schedules.Schedule[11] memory schedules;

        // unlock on start
        schedules[0].start =      1649937600;         // April 14 2022 12:00:00 UTC
        schedules[0].duration =   0;
        schedules[0].interval =   0;
        // Round A1
        schedules[1].start =      1649937600;         // April 14 2022 12:00:00 UTC
        schedules[1].duration =   540 days;
        schedules[1].interval =   1 days;
        // Round A2
        schedules[2].start =      1649937600;         // April 14 2022 12:00:00 UTC
        schedules[2].duration =   540 days;
        schedules[2].interval =   1 days;
        // Round B
        schedules[3].start =      1649937600;         // April 14 2022 12:00:00 UTC
        schedules[3].duration =   540 days;
        schedules[3].interval =   1 days;
        // Public Sale
        schedules[4].start =      1649937600;         // April 14 2022 12:00:00 UTC
        schedules[4].duration =   540 days;
        schedules[4].interval =   1 days;
        // Advisors
        schedules[5].start =      1649937600;         // April 14 2022 12:00:00 UTC
        schedules[5].duration =   360 days;
        schedules[5].interval =   1 days;
        // Airdrop
        schedules[6].start =      1649937600;         // April 14 2022 12:00:00 UTC
        schedules[6].duration =   540 days;
        schedules[6].interval =   1 days;
        // Staking & Farming
        schedules[7].start =      1649937600;         // April 14 2022 12:00:00 UTC
        schedules[7].duration =   0;
        schedules[7].interval =   0;
        // Team
        schedules[8].start =      1649937600;         // April 14 2022 12:00:00 UTC
        schedules[8].duration =   720 days;
        schedules[8].interval =   1 days;
        // Marketing
        schedules[9].start =      1649937600;         // April 14 2022 12:00:00 UTC
        schedules[9].duration =   540 days;
        schedules[9].interval =   1 days;
        // Company reserve
        schedules[10].start =     1649937600;         // April 14 2022 12:00:00 UTC
        schedules[10].duration =  720 days;
        schedules[10].interval =  1 days;

        Amounts memory amounts;

        amounts.sale =          100_000_000 ether;
        amounts.advisors =       35_000_000 ether;
        amounts.airdrop =         2_500_000 ether;
        amounts.staking=         15_000_000 ether;
        amounts.team =           35_000_000 ether;
        amounts.marketing =      45_000_000 ether;
        amounts.reserve =       242_500_000 ether;
        amounts.liquidity =      25_000_000 ether;

        Addresses memory addresses;

        addresses.owner =         msg.sender;
        addresses.fundraising =   msg.sender;
        addresses.advisors =      msg.sender;
        addresses.airdrop =       msg.sender;
        addresses.staking =       msg.sender;
        addresses.team =          msg.sender;
        addresses.marketing =     msg.sender;
        addresses.reserve =       msg.sender;
        addresses.liquidity =     msg.sender;

        token = IERC20(_token);
        sale = ICrowdSale(_sale);
        wallet = IVestingWallet(_wallet);
        depositor = ITokenDepositor(_depositor);

        // distribute tokens
        uint256 amount = token.balanceOf(msg.sender);
        token.transferFrom(msg.sender, address(this), amount);
        token.transfer(_sale, amounts.sale);
        token.transfer(addresses.liquidity, amounts.liquidity);

        // configure CrowdSale
        sale.setToken(_token);
        sale.setBUSD(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));
        sale.setFundraisingWallet(payable(addresses.fundraising));
        sale.setVestingWallet(_wallet);
        sale.setPrice(BASE_PRICE);
        for (uint256 i; i < stages.length; i++) {
            Stages.Stage memory stage = stages[i];
            sale.setStage(i, stage.start, stage.end, stage.bonus, stage.minInvestmentLimit, stage.hardcapInTokens, stage.vestingSchedule, stage.unlockedOnTGE, stage.invested, stage.tokensSold, stage.whitelist);
        }

        // configure VestingWallet
        wallet.setToken(_token);
        for (uint256 i; i < schedules.length; i++) {
            wallet.setVestingSchedule(i, schedules[i].start,   schedules[i].duration,  schedules[i].interval);
        }

        // configure TokenDepositor
        depositor.setToken(_token);
        depositor.setVestingWallet(_wallet);
        token.transfer(_depositor, amounts.advisors + amounts.airdrop + amounts.staking + amounts.team + amounts.marketing + amounts.reserve);
        depositor.deposit(10,  5, addresses.advisors,   amounts.advisors);
        depositor.deposit(10,  6, addresses.airdrop,    amounts.airdrop);
        depositor.deposit( 0,  7, addresses.staking,    amounts.staking);
        depositor.deposit( 0,  8, addresses.team,       amounts.team);
        depositor.deposit( 0,  9, addresses.marketing,  amounts.marketing);
        depositor.deposit( 0, 10, addresses.reserve,    amounts.reserve);

        // transfer ownership
        IOwnable(_token).transferOwnership(addresses.owner);
        IOwnable(_sale).transferOwnership(addresses.owner);
        IOwnable(_depositor).transferOwnership(addresses.owner);
        IOwnable(_wallet).transferOwnership(addresses.owner);
    }

}
