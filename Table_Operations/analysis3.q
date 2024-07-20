// Given a table:
q)t:([]d1:1 2 3 4 5; d2:10 20 30 40 50; func:`add`multiply`add`add`multiply)
// d1 d2 func
// --------------
// 1  10 add
// 2  20 multiply
// 3  30 add
// 4  40 add
// 5  50 multiply


// a) Compute col res where func is applied to d1 and d2, assuming all functions take 2 args
// i.e:
// ([] d1:1 2 3 4 5; d2:10 20 30 40 50; func:`add`multiply`add`add`multiply; res:11 40 33 44 250)
// d1 d2 func     res
// ------------------
// 1  10 add      11
// 2  20 multiply 40
// 3  30 add      33
// 4  40 add      44
// 5  50 multiply 250

// ans:
// Make a dictionary for `add`multiply as these two aren't defined yet
dict:`add`multiply!(+;*)

// This is wrong because you want to use () instead of []
update res:(dict[func]).'[d1;d2] from t

// t[`d1] will always have values in list
// since we are applying each column values need to use flip to make d1 & d2 into lists
update res:(dict[func]).' flip (d1;d2) from t

// b) Add2 & add to cols d1 & d2, try using function below and notation
q)add2:{x+2}; add:{$[x>10;x+2;x+3]}; dcols:`d1`d2


// ans:
q)t[dcols]:add2 t[dcols]

// Using amend
q)@[t;dcols;add2]


// Since add does not support vectors straightaway
q)(add'') t[dcols]


// c) Chage the table like the below
func    | d1    d2
--------| --------------
add     | 1 3 4 10 30 40
multiply| 2 5   20 50


ans:
q)select d1,d2 by func from t


// d) Change columns names from `d1`d2 -> `price`size


ans:
//xcol for renaming
q)t:`price`size xcol t




// e) Get accumulating weighted-average prices by func from a table, meaning taking account of not just the previous record but all previous records.

q)
price size func     avgPrice
----------------------------
1     10   add      10
2     20   multiply 20
3     30   add      25
4     40   add      32.5
5     50   multiply 41.42857


ans:
// Use sums to solve this question
q)update avgPrice:(sums price*size)%sums price by func from t


// f) Combine multiple columns values into one column in kdb
q)ccols:`price`size`func

price size func     all_bid
----------------------------------
3     12   add      3 12 `add
4     22   multiply 4 22 `multiply
5     32   add      5 32 `add
6     42   add      6 42 `add
7     52   multiply 7 52 `multiply


// ans:
// t[ccols] will give you a list so flip this to make it the same length
q)update all_bid: flip t[ccols] from t

// Use # (take) which on tables will return a subset of columns. 
// As a table in kdb is simply a list of dicts, use value each on this table to get the values for each row:
q)update all_bid:value each ccols#t from t

// Use parse to determine functional form
q)0N!parse"update All_bid:flip(Bid1px;Bid2px;Bid3px) from table";
(!;`table;();0b;(,`All_bid)!,(+:;(enlist;`Bid1px;`Bid2px;`Bid3px)))

// Replicate the functional form, swapping in your Bidcols list
q)![table;();0b;(1#`All_bid)!enlist(flip;enlist,Bidcols)]
