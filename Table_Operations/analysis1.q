csvPath:getenv[`AX_WORKSPACE],"/Data/trade.csv"

quote: ("dstffff";enlist",") 0: hsym `$getenv[`AX_WORKSPACE],"/Data/quote.csv"
trade: ("dstff";enlist",") 0:hsym `$getenv[`AX_WORKSPACE],"/Data/trade.csv"

dfd:.Q.fs[{("dstffff";enlist",")0:x}] hsym `$getenv[`AX_WORKSPACE],"/Data/quote.csv"

("dstff";enlist",") 0:hsym `$getenv[`AX_WORKSPACE],"/Data/trade.csv"



\c 20 1000
5#trade
5#quote

count trade
trade,'([]ticker:206357?`AAPL`MSFT`GOOG`TSLA)
quote

// count the tick data number in a day
select count i by sym, date from trade

// calculate daily data first
trade_ld: select volume:sum size, total_volume: sum size*price, close: last price by Stock:sym,date from trade
trade_ld: update rtn: -1+close%prev close by Stock from trade_ld

q1_1: select ADV:avg volume, ADTV: avg total_volume, Volatility: dev rtn by Stock from trade_ld


// 5min data
trade_5m: select close: last price by Stock:sym, date, 5 xbar time.minute from trade
trade_5m: update rtn: -1+close%prev close by Stock from trade_5m;

\c 30 1000
select count i by Stock, date from trade_5m

// 5min volatility
q1_2: select dev rtn *sqrt 50 by Stock from trade_5m

quote_1: update spread_bps: 10000*(ask-bid)%(ask+bid)% 2, qsize:(asize+bsize)%2 by Stock:sym from quote

q1_3: select spread_bps:avg spread_bps, quote_size:avg qsize by Stock:sym from quote_1;

q1: q1_1 pj q1_2 pj q1_3

save `:result/q1.csv


////// Question 2

// use 1min data and then upsampling
trade_1m: select close: last price, volume:sum size by Stock:sym, 1 xbar time.minute, date from trade
trade_1m: update rtn: -1+close%prev close by Stock from trade_1m

// 1min volpct
trade_1m: update volpct: volume % sum volume by date from trade_1m
trade_1m

\c 30 1000
select count i by Stock, date from trade_1m

/ two methods for calculating 5min volatility
/method 1
show vol5: select volatility5: dev rtn * sqrt 240 by date, Stock, 5 xbar minute from trade_1m

/method 2
show vol5: select avg volatility5 by Stock, minute from vol5

show q2_1: vol5

q2_2: vol5

q2_2: update volpct: sum volpct by 5 xbar minute, date from trade_1m

show q2_2: select avg volpct by minute from q2_2

show q2_3: select spread:avg spread_bps, qsize: avg qsize by 5 xbar time.minute from quote_1 where sym = `$"600030.SHSE"

q2: q2_1 lj q2_3 uj q2_2
q2

save `:result/q2.csv


// Open High Low Close
ohlc: select open:first price, high:max price, low:min price, close:last price by sym, date, 1 xbar time.minute from trade

// Volume Weighted Average Price where price > avg price
vwap: select vwap: size  wavg price by sym, date, time.minute from trade where price > (avg;price) fby sym




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
sharpeRatio: avg trades`pnl % dev trades`pnl