# KDB

Important & Useful Functions to remember

```q
_Cut
q)2 4 9 _ til 10           /first row item starts at index 2, second row starts from index 4...
2 3
4 5 6 7 8
,9


_Drop
q)0 1 2 3 4 5 6 7 8_5      /drop the 5th item
0 1 2 3 4 6 7 8


Sublist
q)2 3 sublist 1 2 3 4 5 6 //From index 2, take 3 elements
3 4 5


#Take
q)2 4#`Arthur`Steve`Dennis	/A 2×4 matrix
Arthur Steve  Dennis Arthur
Steve  Dennis Arthur Steve


^Fill
q)1 2 3 4 5^6 0N 8 9 0N   /Fills each null of the 2nd list with corresponding index value in the first list
6 2 8 9 5
```

Table Operations

0. Generate a table of count 100 with ticker, date, time, price, size

ans:
q)tab:([]ticker:100?`AAPL`MSFT`GOOG;date:100?.z.D+til 10;time:100?.z.T;price:100?100f;size:100?150i)


a) Calculate VWAP per ticker, with aggregation over 10 minutes period, where each exceeds avg price for that ticker group.

ans:
q)select vwap: size wavg price by date from tab
q)select ticker by date, 60 xbar `time$time.minute from tab where date.month = `month$.z.D
q)select from tab where size < (avg;size) fby ticker

q)select vwap: size wavg price by date, 60 xbar `time$time.minute from tab where date.month = `month$.z.D, size > (avg;size) fby ticker

b) How can you write the following differently? 

q)select from tab where ticker in `AAPL`MSFT


ans:
q)select from tab where any ticker =/: `appl`msft
q)raze {select from tab where ticker =x} each `msft`appl // projection; faster than using in


c) Create a column called venue on a ticker values and order the columns in a following way
ticker;venue;date;timeprice;size

ticker  venue date       time         price     size
-------------------------------------------------
GOOG Z     2024.05.24 09:01:51.146 5.81007   139
AAPL OQ    2024.06.02 12:12:03.051 56.82217  34
MSFT N     2024.06.02 16:44:12.233 28.95719  148


ans:
// xcols for reordering
// xcol for renaming
q)tab:`ticker`venue xcols update venue:(`AAPL`MSFT`GOOG!`OQ`N`Z)[ticker] from tab



d) Update the table with a new column, sym, which is [ticker].[venue] for each row, so we've got a unique ID indicating stock and venue:
AAPL.OQ
GOOOG.z,,,

ans:
// Using .Q.dd which joins two symbols
q)update sym:.Q.dd'[ticker;venue] from tab

// Using each left and right
q)update sym:`$((string ticker),' ".",/:(string venue)) from tab


e) Return the rows that give maximum value of a trade per sym

ticker venue date       time         price    size
--------------------------------------------------
GOOG   Z     2024.05.28 10:59:00.065 99.07116 140
AAPL   OQ    2024.05.26 17:16:44.575 94.71555 136
MSFT   N     2024.06.02 13:19:22.549 96.14594 104
 

ans:
//This gives the right answer but want to drop wvalue (price * size) column
q)sd:(select from (update wvalue:(quantity*price) from t) where price = (max;price) fby ticker)

// Since drop _ only takes multiple columns, add null value to use it 
q)((),`wvalue) _ sd

// Using delete
q)delete wvalue from sd

// Using amend
q).[sd;(); ((),`wvalue) _]




0.5. Concatenating two columns of a table in select

q)tab:([]firstname:`John`Jia`Jai`Jac;lastname:`James`Jain`Jadeja`Jones;age:1+4?30)

a) Two columns as lists
q)
name
----------
John James
Jia  Jain
Jai  Jadeja
Jac  Jones

ans:
select name:(firstname,'lastname) from tab


b) Two columns as String
Join them as string (Citadel)
fullname     age
----------------
"John James" 13
"Jia Jain"   9
"Jai Jadeja" 11
"Jac Jones"  2


ans:
q)select fullname: ((string firstname),'" " ,'(string lastname)), age from tab


c) Two columns as String
A mixed list is formed if the columns are of different type. If you cast the columns to string before each-both join, a concatenated string is formed. You can also insert a character using ,'.
col
--------------
"JohnJames/19"
"JiaJain/24"
"JaiJadeja/25"
"JacJones/19


ans:
q)select col:((string firstname),'(string lastname),'"/",'(string age)) from tab
If you need multi character delimiters, use sv. A nice advantage of this method is you don’t have to individually convert each column to string.

d)
col
-----------------
"John--James--19"
"Jia--Jain--24"
"Jai--Jadeja--25"
"Jac--Jones--19"

ans:
q)select col:({"--" sv x} each string (firstname,'lastname,'age)) from tab


e) Make the table as below
firstname lastname age Dear
----------------------------------
John      James    13  "Dear John"
Jia       Jain     9   "Dear Jia"
Jai       Jadeja   11  "Dear Jai"
Jac       Jones    2   "Dear Jac"

ans:
To add a string as prefix and postfix to a column, you can use /:(each right) and \:(each left) respectively.
q)update Dear:("Dear ",/: string firstname) from `tab


f) Split a column into two (dear & name)
q)
dear name
---------
Dear John
Dear Jia
Dear Jai
Dear Jac


ans:
// Using select
q)select dear:"S"$4#'Dear, name:"S"$5_'Dear from tab

// Using exec
q)flip exec `dear`name!"SS"$(5#;4_)@/:\: Dear from tab
q)flip exec `dear`name!"SS"$(#[5];_[4])@/:\: Dear from tab


0.7
Given a table:
q)t:([]d1:1 2 3 4 5; d2:10 20 30 40 50; func:`add`multiply`add`add`multiply)
d1 d2 func
--------------
1  10 add
2  20 multiply
3  30 add
4  40 add
5  50 multiply


a) Compute col res where func is applied to d1 and d2, assuming all functions take 2 args
i.e:
([] d1:1 2 3 4 5; d2:10 20 30 40 50; func:`add`multiply`add`add`multiply; res:11 40 33 44 250)
d1 d2 func     res
------------------
1  10 add      11
2  20 multiply 40
3  30 add      33
4  40 add      44
5  50 multiply 250

ans:
// Make a dictionary for `add`multiply as these two aren't defined yet
dict:`add`multiply!(+;*)

// This is wrong because you want to use () instead of []
update res:(dict[func]).'[d1;d2] from t

// t[`d1] will always have values in list
// since we are applying each column values need to use flip to make d1 & d2 into lists
update res:(dict[func]).' flip (d1;d2) from t

b) Add2 & add to cols d1 & d2, try using function below and notation
q)add2:{x+2}; add:{$[x>10;x+2;x+3]}; dcols:`d1`d2


ans:
q)t[dcols]:add2 t[dcols]

// Using amend
q)@[t;dcols;add2]


// Since add does not support vectors straightaway
q)(add'') t[dcols]


c) Chage the table like the below
func    | d1    d2
--------| --------------
add     | 1 3 4 10 30 40
multiply| 2 5   20 50


ans:
q)select d1,d2 by func from t


d) Change columns names from `d1`d2 -> `price`size


ans:
//xcol for renaming
q)t:`price`size xcol t




e) Get accumulating weighted-average prices by func from a table, meaning taking account of not just the previous record but all previous records.

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


f) Combine multiple columns values into one column in kdb
q)ccols:`price`size`func

price size func     all_bid
----------------------------------
3     12   add      3 12 `add
4     22   multiply 4 22 `multiply
5     32   add      5 32 `add
6     42   add      6 42 `add
7     52   multiply 7 52 `multiply


ans:
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



1.
Implement the following without using the built in function
a) distinct

ans:
f:{key group x}


b) differ
q)differ`IBM`IBM`MSFT`CSCO`CSCO
10110b

ans:
q)(<>':)`IBM`IBM`MSFT`CSCO`CSCO
10110b

c. Maximum and minimum

q)max 2 5 9 1
9
q)min 2 5 9 1
1

ans:
q)f:(|/)	/max
q)f:(&/)	/min


2.
generate odd numbers up to n

ans:
f:{[n] (floor(count n)%2)  sublist  1+ 2*til n}
f:{[n](floor (count til n)%2) sublist 1+2*til n}
f:{[n] (til n)where (til n) mod 2}


3.
q)f[5]
5 4 3 2 1

ans:
f:{1+reverse til n}
   

4.
find sum of digits of integer n
q)f "123"
6

ans:
q)sum "I"$'string 123
6

5.
q)f[5]
(1;2 2;3 3 3;4 4 4 4;5 5 5 5 5)

ans:
q)f:{(1+til x)#'1+til x}


6.
generate an n by n identity matrix
q)f[5]
1 0 0 0 0
0 1 0 0 0
0 0 1 0 0
0 0 0 1 0
0 0 0 0 1

ans:
q)f{d:til x; d=/:d} /using each right
q)f:{(2#x)#1,x#0} /using take(#) to make n x n matrix
q)f:{(x;x)#1,x#0} /using take(#) to make n x n matrix



7.
q)f[5]
0 1 2 3 4
1 1 2 3 4
2 2 2 3 4
3 3 3 3 4
4 4 4 4 4

ans:
bdd:{{@[x;y;1+]}\[til x;til @' til x]}
    
+
8.
extract main diagonal of a square matrix

q)d:(1 0 0 0 0;0 1 0 0 0;0 0 1 0 0;0 0 0 1 0;0 0 0 0 1)
q)d
1 0 0 0 0
0 1 0 0 0
0 0 1 0 0
0 0 0 1 0
0 0 0 0 1
q)f[d]
1 1 1 1 1

ans:
f:{x @' (til count x)} 
    

9.
q)f "abcde"
"AbCdE"

ans:
q)f:{@[x;where not (til count x) mod 2;upper]}


10.
find index of largest element in list
q)x:12 8 10 1 10
q)f[x]
0

ans:
f:{where x=max x}
f:{x?max x}


11.
find most frequent element in list
q)x:12 8 10 1 10
q)f[x]
10
count each l

ans:
q)f:{first key desc(key group x)!count each value group x}
q)f:{first key desc count each group x} 


12.
q)f "abc"!5 2 1
"aaaaabbc"

ans:
f:{raze(value x) #' key x}


From Conor Clark and Lunn
what is the max profit you could get from trading?
q)t:10 4 5 6 8 9
q)f[t]
5

ans: 
q)max raze {?[x<0;(count x)#0;x]} each 1_{(next x)-first x}\[5;t]
q)f:{max (raze/) 1_{(next x)-first x}\[count x;x]}




Random Questions

13.
Fibonacci numbers

ans:
q)Fib:{x,sum –2#x}/[10;(0;1)]



14.
Pascal’s Triangle?

ans:
q)tri:{(+':) x,0}\[7;1]
q)tri:{(+) prior x,0}\[7;1]


a) Applicable for both Fibonacci Sequence & Pascal’s Triangle, change solution to terminate when the size of the list reaches a count of 10

ans:
q)Fib:{x,sum -2#x}/[{10> count x};0 1]
q)Pas:{(+':) x,0}\[{10> count x};1]


b)Change solution to terminate when a value of greater than 100 is reached

ans:
q)Pas:{(+)prior x,0}\ [{all 100>x};1]
q)Fib:{x, sum -2#x}\[{100>max x};0 1]


15.
Factorial!

ans:
q)fact:{1 */ 1+til x}
K code:
q){1*/1+!x}


16.
Is Prime?

ans:
q)isprime:{ c:x mod 2+til floor sqrt x; not (c?0) < count c }
q)isprime:{2=sum 0=x mod 1+til x}'


17.
Primes to X

ans:
//using mod from the previous one
q)Primes: i where isprime i:1+til 1000

// generate all the composite numbers and eliminate them.
q)Primes:{{x except raze x*/:\:x}1_1+til x}

//Using Over
q)primes:{{$[min y mod x;x,y;x]}\[2;2+til x]}


18.
Find the first number which can be divided evenly by every number up to 10

ans:
q){x+1}/[{not all 0=x mod 1+ til 10};1]
q){x+1}/[{sum x mod 1+ til 10};1]


19.
Fill any empty items in the list with the previous non-empty item.

q)str:("abc";"";"";"mn";"";"wxyz")

q)f str
"abc"
"abc"
"abc"
"mn"
"mn"
"wxyz"

ans:
q)f:{{$[count y;y;x]}\[x]}
q){x maxs(til count x)*0<count each x}str  //performs better on longer lists.


20.
a)
Given strings x and y, is x a rotation of the characters in y?
Example of code:
f["foobar";"barfoo"]
1b
f["fboaro";"foobar"]
0b
f["abcde";"deabc"]
1b

ans:
f:{x in (1 rotate)scan y}
f:{x in (rotate[1]\) y}

b)
Write rotate in a different way so that it would run faster

q)f [3;"abcde"]
"deabc"

q)f [-3;"abcde"]
"cdeab"

q)(f[1]\) "abcde"
"abcde"
"bcdea"
"cdeab"
"deabc"
"eabcd"

ans:
q)f:{raze reverse (0;$[x<0;count[y]+x;x]) _ y}



21.
Fizzbuzz?
Write a monadic function that takes an integer input such that it returns the symbol `fizz if the number is divisible by 3, `buzz if the number is divisible by 5, `fizzbuzz if the number is divisible by both 3 and 5 and just returns the number itself otherwise. Pass the numbers 1-100 into this function.
Input: 1 2 3 4 5 6 7… 

Output: 1 2 fizz 4 buzz 6 7…

ans:
// Using Case iterator
q)fizzbuzz:{(sum 1 2* 0=(1+til x) mod/: 3 5)'[`$string ab;`fizz;`buzz;`fizzbuzz]}
// Using dictionary, ^ fill method
q)fizzbuzz:{(`$string 1+til x)^(1 2 3!`fizz`buzz`fizzbuzz) (sum 1 2* 0=(1+til x) mod/: 3 5)}
//using conditionals
q)fizzbuzz:{{$[0=x mod 3;$[0=x mod 5;`fizzbuzz;`fizz];0=x mod 5;`buzz;x]} each x} //Projection


22.
Sort yourself out
Alphabetical filing systems are passé. It’s far more Zen to organize words by their histograms! Given strings x and y, do both strings contain the same letters, possibly in a different order?


q)f["teapot";"toptea"]
1
q)f["apple";"elap"]
0
q)f["listen";"silent"]
1

ans:
q)f:{asc[x]~ asc x}


23.
Precious snowflakes
It’s virtuous to be unique, just like everyone else. Given a string x, find all the characters which occur exactly once, in the order they appear.


q)f "somewhat heterogenous"
"mwa rgnu"
q)f "aaabccddefffgg"
"be"

ans:
q)f:{where 1=count each group x}


24.
Size matters
Sometimes small things come first. Given a list of strings x, sort the strings by length, ascending.

q)f ("books";"apple";"peanut";"aardvark";"melon";"pie")
"pie"
"books"
"apple"
"melon"
"peanut"
"aardvark"

ans:
q)f:{x iasc count each x}


25.
Given a string x consisting of words (one or more non-space characters) which are separated by spaces, reverse the order of the characters in each word.

q)f "a few words in a sentence"
"a wef sdrow ni a ecnetnes"
q)f "zoop"
"pooz"
q)f "one two three four"
"eno owt eerht ruof"

ans:
q)f:{" " sv reverse each " " vs x}


26.
Expansion mansion
Given a string x and a boolean vector y, spread the characters of x to the positions of 1s in y, filling intervening characters with underscores.


q)f["fbr";100101b]
"f__b_r"
q)f["bigger";0011110011b]
"__bigg__er"

ans:
Note how the mapping indicies are being formed using "sums"
q)f:{("_",x) y*sums y}
q)f:{"_"^x -1+y*sums y}


27.
C_ns_n_nts
Given a string x, replace all the vowels (a, e, i, o, u, or y) with underscores.

q)d:"FLAPJACKS"
q)f "FLAPJACKS"
"FL_PJ_CKS"
q)f "Several normal words"
"S_v_r_l n_rm_l w_rds"

ans:
V:"AEIOUYaeiouy"            / vowels
{?[x in V;"_";x]}           / Vector Conditional; in
{@[x;where x in V;:;"_"]}   / Amend At; in
{$["j";x in V]'[x;"_"]}     / Case
{(x;"_")x in V} each        / index
ssr/[;V;"_"]                / ssr (AV)


28.
Title redacted
Given a string x consisting of words separated by spaces (as above), and a string y, replace all words in x which are the same as y with a series of x.

q)f["a few words in a sentence";"words"]
"a few XXXXX in a sentence"
q)f["one fish two fish";"fish"]
"one XXXX two XXXX"
q)f["I don't give a care";"care"]
"I don't give a XXXX"

ans:
f:{ssr[x;y;count [y]#"X"]}


29.
It’s more fun to permute
My ingenious histogram-based filing system has a tiny flaw: some people insist that the order of letters in their names is significant, and now I need to re-file everything. Given a string x, generate a list of all possible re-orderings of the characters in x. Can you do this non-recursively?


q)f "xyz"
"xyz"
"xzy"
"yzx"
"yxz"
"zxy"
"zyx"

ans:
q){(1 0#x) {raze({raze reverse 0 1 _ x}\)each x,'y}/ x} // I don't know how this works
q){x {flip[y]where all each til[x] in/: flip[y]}[s;] s vs til"j"$s xexp s:count x}
q){x {flip[y]where x=count each distinct each flip[y]}[s;] s vs til"j"$s xexp s:count x}


30.
Trimming locals
We have used up nearly our entire monthly allowance of parens and local variables. And mislaid the trim keyword. Until we can locate it, we need a substitute that uses no parens, defines no local variables, and of course – tests only once for spaces.


q)f "   abc def  "
"abc def"

ans:
q){{y _x}/[x;] 1 -1*?'[(1 reverse\null x);0b]}[x]


31.
Trimming inside
q)f "the    quick brown     fox"
"the quick brown fox"

ans:
//Using each prior to compare characters with “or”
q){x where not(&':)" "=x} "the    quick brown     fox"
"the quick brown fox"

32.
Pack consecutive duplicates of list elements into sublists
q)d:`a`a`a`a`b`c`c`a`a`d`e`e`e`e
q)f `a`a`a`a`b`c`c`a`a`d`e`e`e`e
`a`a`a`a
,`b
`c`c
`a`a
,`d
`e`e`e`e

ans:
q)f:{(where differ x) cut x}

33.
Run-length encoding of a list
q)f `a`a`a`a`b`c`c`a`a`d`e`e`e`e
4 `A
1 `B
2 `C
2 `A
1 `D
4 `E

ans:
q)f:{d:(where differ x) cut x;(count each d),'upper 1#' d}

34.
Duplicate the elements of a list
q)d:`a`b`c`c`d
q)f `a`b`c`c`d
`A`A`B`B`C`C`C`C`D`D

ans:
q)f:{upper raze/ 2#/: x}


35.
Drop every N’th element from a list
q)d:`a`b`d`e`f`g`h`i`k

q)f [(`a`b`d`e`f`g`h`i`k);3]
`a`b`e`f``h`i


ans:
q)f:{{x _ y}/[x;] where 0=(1+til[count [x]]) mod y}  //my solution
q)f:{raze _'[(y cut x);y-1]}  //more concise
q)f:{x where (count x)#((y-1)#1b),0b}  //more effiecient as this does not invovle recursion


36.
Extract a slice from a list
q)d:`a`b`d`e`f`g`h`i`k

q)f [(`a`b`d`e`f`g`h`i`k);3 7]
`d`e`f`g

ans:
q)f:{first ((y-1);z)_x}
q)f:{(max(y-1;0))_(neg (count x)-min(z;count x))_x}


37.
Insert an element at a given position into a list

q)f[`a`b`c`d;`alfa;2]
`a`b`alfa`c`d

ans:
q)f:{first [(0;z)_x)],y,last [(0;z)_x)]}


38.
P18
Generate the combinations of K distinct objects chosen from the N elements of a list

q)f["abcde";4]
"abcd"
"abce"
"abde"
"acde"
"bcde"

ans:
q)f:{x reverse where each flip 2 vs where y=sum 2 vs til 7h$2 xexp count x}

39.
Sorting a list of lists according to length of sublists

q)df:(`a`b`c;`d`e;`f`g`h;`d`e;`i`j`k`l;`m`n;`o)

a)According to their length
q)f df
`o
`d`e
`d`e
`m`n
`a`b`c
`f`g`h
`i`j`k`l

ans:
q)f:{x iasc count each x}


b)According to their length frequency
q)f[df]
`i`j`k`l
`o
`a`b`c
`f`g`h
`d`e
`d`e
`m`n

ans:
q)f:{raze x a iasc count each a:group count each x}


40.
a)
Determine the greatest common divisor of two positive integer numbers
q)gcd 30 50
10

ans:
q)gcd:{1+last where all each 0=x mod/: 1+til min x}

// this one is faster as this one needs less calculations
q)gcd:{$[y=0;x;.z.s[y;x mod y]]}

b)
Determine the least common multiple of two integers

ans:
lcm:{div[x*y] gcd[x;y]}

Squarepoint Capital

41.
Generate all fridays between two dates


ans:
q)friday:{[sdate;edate] sdate + where 6= (sdate + til [sdate - edate])  mod 7}


42.
Write a function to output any dictionary keys that have the same dictionary values.

q)d:`a`b`c`d`x`y`z!3 2 1 3 2 4 6
q)f[d]
`a`d
`b`x

ans:
f:{l where 1<count each l:value group x}


43.
Write a function to generate a matrix like:
q) f[3]
1 2 3
2 3 4
3 4 5


ans:
// Using Scan (my answer)
q)f:{{x+1}\[x-1;1+til x]}

// Usint each left or right (what interviewer wanted)
// Note that it is a identity matrix
f:{til[x] +\:til x}


44.
Apply list of functions f1:{x+y+z},f2:{x+y-z},f3:{x-y+z} to vector a:1 2 3. Do not use "each".
f1:{x+y+z};f2:{x+y-z};f3:{x-y+z};a:1 2 3

ans:
q)(f1;f2;f3).\:a


45.
Give some q code for generating a list of 10 random 4 character symbols (all upper case)

ans:
q)upper rand each 10#`$string 4


46.
Create a list of dictionaries from (((1 2);(`a`b));((`c`d);(3 4))) - result should contain 2 dictionaries. Do not use a lambda.
a:(((1 2);(`a`b));((`c`d);(3 4)))

ans:
q)(!)./:(((1 2);(`a`b));((`c`d);(3 4)))


48
Show how to save a table to a | delimited and fixed width file. The table should have float, int, symbol, string, character typed columns.

ans:
“|” 0: table (“FISC”;widths) 0:(filehandle;offset;length)


49.
Save the below table in the following formats:
a)	Serialised file
b)	Splayed table
c)	Date partitioned, `p# sym file table (no par.txt)
d)	Date partitioned, `p# sym file table(with par.txt)
Do not use .Q.hdpf or .Q.dpft. Other .Q. commands can be used.


ans:
a)
`:dir set table

b)
`:dir/ set .Q.en[`:symdir;] table

c)
`:/db/date/table/ set .Q.en[`:symdir; (select from table where date=date)]

d)
`:/db/1/date1/table/ set .Q.en[`:symdir;] (select from table where dateColumn=date1)
`:/db/2/date2/table/ set .Q.en[`:symdir;] (select from table where dateColumn=date2)
`:/db/par.txt 0: (“/1”;”/2”)


50.
We have a very large csv that needs to be written to disk
a) How would you parse this csv 

2021.07.04,AAPL,10.0,A
2021.07.04,META,10.0,B
2021.07.05,AAPL,10.0,C
2021.07.05,MSFT,5.0,A
2020.07.04,TSLA,4.0,B


ans:
// D->date; S->symbol; *->string; blank->not loading that column
// no enlist -> no header
// enlist csv = enlist ","

// With Header
("DSFS* ";enlist csv) 0: path/file.csv 


//Without Header
("DSFS* ";csv) 0: path/file.csv 

b) How would you parse this if it was too big to hold in memory? Store in a file called `:newfile using dictionary method



ans:
q).Q.fs[{("DSFS* "; ",") 0:x}]`:path/file.csv //* -> string; blank -> not loading that column
q).Q.fs[{`:newfile upsert flip colnames!("DSFS* ";",")0:x]}] `:path/file.csv



Squarepoint Capital
51.
Create a function to randomly sort lists? 
q)d:1 2 3 4 5 6
q)func 1 2 3 4 5 6
5 2 1 3 4 6


ans:
// ? deal; items are selected from different indexes
func:{neg [count x]?x}
// 0N? permute; returns the items of x or til x in random order




52.
Create a function that imitates .Q.fu without using .Q.fu
.Q.fu applies x to the distinct items of y.

q)d: 1 1 1 2 3 4; foo :{x*x}


ans:
func:{
    ind:y ? distinct y;
    y[ind]:x @ y[ind];
    :y
    }

53.
Show how to compress files saved to disk using 2 different methods.

ans:
-19!(`:sourceFile;`:targetFile;BlockSize;Algorithm;compressionLevel)
-19! (`:/db/trade; `:/db/trade_compressed; 16; 1; 0)

.z.zd(`:targetFile; blockSize; alg; level) set table
.z.zd:(17;2;6);`:file set …


54.
How would you reverse the direction of an aj

ans:
I think he was referring to reversing the direction of table being 
Use ajf


55.
How would you split the following vector up into 4 groups where the sum of each group is as homogeneous as possible? 

ans:
Use greedy algorithm

splitToHomogeneousGroups: { 
    / Sort the vector in descending order
    sortedVector: reverse asc x;
    
    / Initialize 4 groups; Initialize sums for each group
    groups:: (();();();()); sumGroup:: 0 0 0 0;
    
    / Distribute elements to the groups
    {
        / Find the index of the group with the minimum sum
        idx: first iasc sumGroup;
        
        / Add the element to the chosen group
        groups[idx]: groups[idx], x;
        
        / Update the sum of the chosen group
        sumGroup[idx]: sumGroup[idx] + x;
    } each sortedVector;
    
    / Return the groups
    groups
 };

/ Sample vector
vector: 100 200 300 400 500 600 700 800 900 1000;

\ Run the function
splitToHomogeneousGroups vector

q)splitToHomogeneousGroups: {vector: x; sortedVector: reverse asc vector; groups:: (();();();()); sumGroup:: 0 0 0 0; {idx: first iasc sumGroup; groups[idx]: groups[idx], x; sumGroup[idx]: sumGroup[idx] + x;} each sortedVector; :groups};


56.
Represent this graph in q as a dictionary
a -> b
a -> c
b -> d


ans:
`a`b`c`d!(`b`c;`d;();())

57.
Define a function 'jw' which is join wrapper function that can take in any join function (except wj), key column list, left-hand table, right-hand table, and performs the join between them.

q)s:([]a:1 2;b:2 3;c:5 7); t:([]a:1 2 3;b:2 3 7;c:10 20 30;d:"ABC")
q)jw[uj;`a`b;s;t]
a b| c  d
---| ----
1 2| 10 A
2 3| 20 B
3 7| 30 C
q)jw[uj;();s;t]
a b c  d
--------
1 2 5
2 3 7
1 2 10 A
2 3 20 B
3 7 30 C
q)jw[lj;`a`b;s;t]
a b c  d
--------
1 2 10 A
2 3 20 B
q)jw[ij;`a`b;s;t]
a b c  d
--------
1 2 10 A
2 3 20 B
q)jw[ej;`a`b;s;t]
a b c  d
--------
1 2 10 A
2 3 20 B

ans:
jw:{[f;c;t1;t2]
    t2:c xkey t2;
    if[f in (uj;ujf); t1:c xkey t1];
    args:(t1;t2);
    if[f~ej; args:enlist[c],args];
    f . args
 }

jw:{[f;c;t1;t2] t2:c xkey t2; if[f in (uj;ujf);t1:c xkey t1]; args:(t1;t2);if[f~ej;args:enlist[c],args]; f . args}


58.
Label Encoding is the method of converting label (categorical) data to numeric data via enumeration. We do this by enumerating the labels, replacing them with numbers starting from 0. Define a function 'lblenc' that takes in a table and symbol column name, and returns the table with the column converted to an integer list (type 7h). The function should encode all symbols as integers, and encoding should start at 0.

q)show shirts:([]sku:0 0 0 0 1 1;size:`s`s`s`s`l`xl;color:`red`blue`yellow`green`white`black;price:29.95 29.95 29.95 29.95 14.99 14.99) 
sku size color  price 
--------------------- 
0   s    red    29.95 
0   s    blue   29.95 
0   s    yellow 29.95 
0   s    green  29.95 
1   l    white  14.99 
1   xl   black  14.99 
q)lblenc[shirts;`size] // encode one feature 
sku size color  price 
--------------------- 
0   0    red    29.95 
0   0    blue   29.95 
0   0    yellow 29.95 
0   0    green  29.95 
1   1    white  14.99 
1   2    black  14.99 
q)lblenc/[shirts;`size`color] // encode multiple features 
sku size color price 
-------------------- 
0   0    0     29.95 
0   0    1     29.95 
0   0    2     29.95 
0   0    3     29.95 
1   1    4     14.99 
1   2    5     14.99

ans:
// My solution; I think mine is better
q)func:{dict:(distinct x y)!til count distinct x y; :![x;();0b;(enlist y)!enlist(`dict;y)]}

// I think mine is better
lblenc:{ 
    r:count[x]#(); 
    g:group x y; 
    r[value g]:til count key g; 
    ![x;();0b;(1#y)!enlist r] 
 }

59.
Longest Streak
Define a function 'streak' that returns the length of the longest streak of a list, as an integer.

q)d:`h`t`h`t`h`h`h`t`t`h`t
q)streak `h`t`h`t`h`h`h`t`t`h`t
3
q)streak ()
0

ans:
f:{max deltas where (differ x),1b}


60.
Define a function 'reorder' that takes in an atom/list 'x' and a list 'y', and reorders 'y' by 'x'.

q)x:`f`b;y:`a`b`s
q)reorder[`s;`a`b`s]
`s`a`b
q)reorder[`s`b;`a`b`s]
`s`b`a
q)reorder[`f`b;`a`b`s]
`b`a`s


ans:
reorder:{(x where x in y),y where not y in x:(),x}


61.
Define a function 'sleep' that behaves similarly to the Unix system command 'sleep'. The function should receive a 'time' as the input argument.

q)\t sleep each 1e3*1 2 5 / seconds
7999
q)\t sleep 500 / millis
499

hint: use while!
ans:
sleep:{st:.z.T; while[.z.T<st+x;()]}



62.
Define a function 'collapseDict' which takes in a dictionary and returns a dictionary with non-duplicate keys, where values are grouped together by key.

q)d:`a`a`b`b`c!1 2 2 2 3; r:`a`b`c!1 2 3
q)collapseDict `a`a`b`b`c!1 2 2 2 3
a| 1 2
b| 2 2
c| ,3
q)collapseDict `a`b`c!1 2 3
a| 1
b| 2
c| 3

hint (list) (dictionary) dictionary values are replaced by list values

ans:
f:{(value x) (group key x)}



63.
Define a function 'ohenc' that takes in a table and symbol column name, and returns the table with that column removed and N new columns appended (where N is the number of distinct values of the column). The new columns should have the old column name prepended to each new column name (ex. size column becomes size_s, size_m, size_l, size_xl, etc. columns). Each new column should contain binary data that represents the occurrence of the label. Each row should have only one occurrence of a transformed label.

q)show shirts:([]sku:0 0 0 0 1 1;size:`s`s`s`s`l`xl;color:`red`blue`yellow`green`white`black;price:29.95 29.95 29.95 29.95 14.99 14.99) 
sku size color  price 
--------------------- 
0   s    red    29.95 
0   s    blue   29.95 
0   s    yellow 29.95 
0   s    green  29.95 
1   l    white  14.99 
1   xl   black  14.99 
q)ohenc[shirts;`size] // encode one feature 
sku color  price size_s size_l size_xl 
-------------------------------------- 
0   red    29.95 1      0      0 
0   blue   29.95 1      0      0 
0   yellow 29.95 1      0      0 
0   green  29.95 1      0      0 
1   white  14.99 0      1      0 
1   black  14.99 0      0      1 


ans:
ohenc:{d:distinct v:x y; ((),y) _ x,'flip (`$(string[y],"_"),/:string d)!d=\:v}


64.
Define a function 'stt' that takes in a list or table and a test set ratio, splits the data into two lists/tables based on the test set ratio, and returns a two item list with the first item representing the training set and the second item representing the test set.

q)show t:([]s:100?`AAPL`MSFT`IBM`TSLA;p:100?400)
s    p
--------
AAPL 372
AAPL 326
TSLA 329
IBM  330
TSLA 50
..
q)s:stt[t;.2]
q)s
+`s`p!(`AAPL`AAPL`TSLA`IBM`IBM`IBM`AAPL`TSLA`TSLA`IBM`MSFT`TSLA`AAPL`AAPL`IBM`IBM`TSLA`IBM`MSFT`TSLA`MSFT`TSLA`AAPL`IBM`AAPL`MSFT`AAPL`IBM`AAPL`AAPL`IBM`MSFT`TSLA`TSLA`AAPL`AAPL`TSLA`MSFT`MSFT`TSLA..
+`s`p!(`AAPL`TSLA`MSFT`IBM`MSFT`TSLA`MSFT`IBM`MSFT`MSFT`MSFT`TSLA`IBM`MSFT`TSLA`TSLA`IBM`TSLA`MSFT`AAPL;213 50 58 97 232 152 67 351 25 323 13 263 224 29 2 383 114 187 137 393)
q)count s[0]
80
q)count s[1]
20
q)stt[`a`b`c`d`e`f`g;.2]
`a`b`c`d`f`g
,`e

ans:
q)f:{var1:?[neg(`long$y * count x);x]; var2:x except var1;(var1;var2)}


65. 
Write a function that returns a vector containing, for each item of x, that number of copies of its index.
This should also returns a list of keys repeated as many times as the corresponding value for a dictionary

q)f 2 3 0 1
0 0 1 1 1 3

q)d:`amr`ibm`msft!2 3 1
q)where d
`amr`amr`ibm`ibm`ibm`msft


ans:
f:{where x}


66.
Write a function that returns for each item in x the index of where it would occur in the sorted list or dictionary.


q)f 2 7 3 2 5
0 4 2 1 3
// if 2 7 3 2 5 is sorted, what is the index that is going to revert sorted list back into original list?


ans:
f:{rank x}
f:(iasc iasc x)


