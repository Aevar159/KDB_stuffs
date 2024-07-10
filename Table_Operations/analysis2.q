// Generate a table of count 100 with ticker, date, time, price, size

// a) ans:
tab:([]ticker:100?`AAPL`MSFT`GOOG;date:100?.z.D+til 10;time:100?.z.T;price:100?100f;size:100?150i)


// b) Calculate VWAP per ticker, with aggregation over 10 minutes period, where each exceeds avg price for that ticker group.

// ans:
select vwap: size wavg price by date from tab
select ticker by date, 60 xbar `time$time.minute from tab where date.month = `month$.z.D
select from tab where size < (avg;size) fby ticker

// Altogether
select vwap: size wavg price by date, 60 xbar `time$time.minute from tab where date.month = `month$.z.D, size > (avg;size) fby ticker

// b) How can you write the following differently? 

select from tab where ticker in `AAPL`MSFT


// ans:
select from tab where any ticker =/: `appl`msft
raze {select from tab where ticker =x} each `msft`appl // projection; faster than using in


// c) Create a column called venue on a ticker values and order the columns in a following way
// ticker;venue;date;timeprice;size

// ticker  venue date       time         price     size
// -------------------------------------------------
// GOOG Z     2024.05.24 09:01:51.146 5.81007   139
// AAPL OQ    2024.06.02 12:12:03.051 56.82217  34
// MSFT N     2024.06.02 16:44:12.233 28.95719  148


ans:
// xcols for reordering
// xcol for renaming
tab:`ticker`venue xcols update venue:(`AAPL`MSFT`GOOG!`OQ`N`Z)[ticker] from tab



// d) Update the table with a new column, sym, which is [ticker].[venue] for each row, so we've got a unique ID indicating stock and venue:
// AAPL.OQ
// GOOOG.z,,,


// ans:
// Using .Q.dd which joins two symbols
update sym:.Q.dd'[ticker;venue] from tab

// Using each left and right
update sym:`$((string ticker),' ".",/:(string venue)) from tab


// e) Return the rows that give maximum value of a trade per sym

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
