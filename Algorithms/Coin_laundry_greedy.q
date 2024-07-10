//The Coin Change problem involves finding the minimum number of coins that make a given amount.

coinChange: {
    / Assume coins are sorted in descending order
    coins::x;
    amount::y;
    result::();

    / Iterate through coins and calculate the number of each coin needed
    {
        numCoins: amount div x;        
        amount:: amount mod x;
        result,: numCoins;
        } 
    each coins;
    
    result
    };

/ Example usage
coins: 25 10 5 1;
amount1:63;
amount2:102;

coinChange[coins; amount1]
coinChange[coins; amount2]

