// contracts/Escrow.sol
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Kovan
     * Aggregator: ETH/USD
     * Address: 0x9326BFA02ADD2366b30bacB125260Af641031331
     */
    constructor() public {
        priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
    }
    
    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
}

contract Escrow {
    address public winner;
    uint256 bet_amount;
    uint256 bet_duration;
    bool bet_long = false;
    bool bet_short = false;
    uint256 time = block.timestamp;

    address user_1;
    address user_2;

    int256 bet_price = PriceConsumerV3.getLatestPrice();
    
    modifier _winner {
        require(msg.sender == winner);
        _;
    }

    function deposit_short() public payable {
        require(bet_short =! true && bet_amount <= msg.value);
        bet_short = true;
        user_1 = msg.sender;
    }

    function deposit_long() public payable {
        require(bet_long =! true && bet_amount <= msg.value);
        bet_long = true;
        user_2 = msg.sender;
    }

    function resolve_bet() external returns(address){
        require(block.timestamp >= time + bet_duration);
        int256 price = PriceConsumerV3.getLatestPrice();

        if (price >= bet_price) {
            winner = user_2;
            settle();
        }
        else if (price < bet_price) {
            winner = user_1;
            settle();
        }
        return winner;
    }

    function settle() internal _winner {
        selfdestruct(payable(winner));
    }
}
