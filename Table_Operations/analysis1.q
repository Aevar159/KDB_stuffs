// Generate a table of count 100 with ticker, date, time, price, size

// a) ans:
tab:([]ticker:100?`AAPL`MSFT`GOOG;date:100?.z.D+til 10;time:100?.z.T;price:100?100f;size:100?150i)
tab:update datetime: date+time from tab


// b) Calculate VWAP per ticker, with aggregation over 10 minutes period, where each exceeds avg price for that ticker group.

// ans:
select vwap: size wavg price by date from tab
select ticker by date, 60 xbar `time$time.minute from tab where date.month = `month$.z.D
select from tab where size < (avg;size) fby ticker

// Altogether
select vwap: size wavg price by date, 60 xbar `time$time.minute from tab where date.month = `month$.z.D, size > (avg;size) fby ticker

// c-i) Calculate simple VWAP
update vwap:size wavg price by ticker from tab

// c-ii) Running VWAP

update vwap2:(sums size*price)%sums size by ticker from tab

// c-iii) Moving VWAP - by tick; over 2 trades window

update vwap3:(2 msum size*price)%(2 msum size) by ticker from tab

// c-iv) Moving VWAP - by time; 1 minute

update vwap4:size wavg price by 1 xbar time.minute, ticker from tab

// c-v) Moving VWAP - by time; preceding 1 minute for each trade, by sym

// wj method
w:(-00:01:00 00:00:00)+\:tab.datetime
wj1[w;`ticker`datetime;tab;(`ticker`datetime xasc select datetime, ticker, vwap1m1:price, size from tab;(wavg;`size;`vwap1m1))]



// tab1: update datetime,sums_size:sums size,sums_vol:sums price*size by ticker from tab
// tab1:aj[`ticker`datetime;tab1;`ticker`datetime xasc select datetime:datetime+00:01:01,ticker,prev_sums_size:sums_size,prev_sums_vol:sums_vol from tab1]
// tab1:delete sums_size, sums_vol, prev_sums_size, prev_sums_vol from update vwap1m2:(sums_vol-0^prev_sums_vol)%sums_size-0^prev_sums_size from tab1

// d) How can you write the following differently? 

select from tab where ticker in `AAPL`MSFT


// ans:
select from tab where any ticker =/: `appl`msft
raze {select from tab where ticker =x} each `msft`appl // projection; faster than using in


// e) Create a column called venue on a ticker values and order the columns in a following way
// ticker;venue;date;timeprice;size

// ticker  venue date       time         price     size
// -------------------------------------------------
// GOOG Z     2024.05.24 09:01:51.146 5.81007   139
// AAPL OQ    2024.06.02 12:12:03.051 56.82217  34
// MSFT N     2024.06.02 16:44:12.233 28.95719  148


// ans:
// xcols for reordering
// xcol for renaming
tab:`ticker`venue xcols update venue:(`AAPL`MSFT`GOOG!`OQ`N`Z)[ticker] from tab



// f) Update the table with a new column, sym, which is [ticker].[venue] for each row, so we've got a unique ID indicating stock and venue:
// AAPL.OQ
// GOOOG.z,,,


// ans:
// Using .Q.dd which joins two symbols
update sym:.Q.dd'[ticker;venue] from tab

// Using each left and right
update sym:`$((string ticker),' ".",/:(string venue)) from tab


// g) Return the rows that give maximum value of a trade per sym

// ticker venue date       time         price    size
// --------------------------------------------------
// GOOG   Z     2024.05.28 10:59:00.065 99.07116 140
// AAPL   OQ    2024.05.26 17:16:44.575 94.71555 136
// MSFT   N     2024.06.02 13:19:22.549 96.14594 104
 

// ans:
//This gives the right answer but want to drop wvalue (price * size) column
sd:(select from (update wvalue:(quantity*price) from t) where price = (max;price) fby ticker)

// Since drop _ only takes multiple columns, add null value to use it 
((),`wvalue) _ sd

// Using delete
delete wvalue from sd

// Using amend
.[sd;(); ((),`wvalue) _]
