// Buy/Sell Signals and pnl 

csvPath:getenv[`AX_WORKSPACE],"/Data/trade.csv"

quote: ("dstffff";enlist",") 0: hsym `$getenv[`AX_WORKSPACE],"/Data/quote.csv"
trade: ("dstff";enlist",") 0:hsym `$getenv[`AX_WORKSPACE],"/Data/trade.csv"

dfd:.Q.fs[{("dstffff";enlist",")0:x}] hsym `$getenv[`AX_WORKSPACE],"/Data/quote.csv"

("dstff";enlist",") 0:hsym `$getenv[`AX_WORKSPACE],"/Data/trade.csv"


// Calculate moving averages
shortMA: mavg[5; trade`price]
longMA: mavg[20; trade`price]

// Generate buy/sell signals
signals:select from (update shortMA:mavg[5; price], longMA:mavg[20; price] from trade) where shortMA > longMA
// Masking using vector conditional, much more efficient as everything is done via vector
signals: update signal:({?[0=x;-1;x]} (>':) price) from signals
// Conditional can be used as well but has to use each so not much efficient
signals: update signal:({$[0=x;-1;1]} each (>':) price) from signals

// Backtest strategy
trades: select from signals where signal=1 or signal=-1
trades: update pnl: price - prev price from trade

update pnl: price - prev price from signals

// Calculate performance metrics
cumulativePNL: sums trades`pnl
sharpeRatio: (avg trades`pnl) % dev trades`pnl

// Open High Low Close
ohlc: select open:first price, high:max price, low:min price, close:last price by sym, date, 1 xbar time.minute from trade

// Volume Weighted Average Price where price > avg price
vwap: select vwap: size  wavg price by sym, date, time.minute from trade where price > (avg;price) fby sym