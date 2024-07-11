/read csv
avgprc:("SFFF";enlist",") 0: hsym `$getenv[`AX_WORKSPACE],"/Data/avgprc.csv"

/Average price of bought 
avgPrcAnaly:update BotAvgPx:(sums prc*abs(trd))%sums abs(trd) from avgprc where tran=`Buy
/Average price of sold
avgPrcAnaly:update SoldAvgPx:(sums prc*abs(trd))%sums abs(trd) from avgPrcAnaly where tran=`Sell
avgPrcAnaly:update BotAvgPx:0f, SoldAvgPx:0f from avgPrcAnaly where i=0

// Altogether
avgPrcAnaly:fills avgPrcAnaly

select from avg_buy where tran=`Buy

/opening
avgPrcAnaly:update avgpx:prc from avgPrcAnaly where tran=`open

/when pos = 0
avgPrcAnaly:update avgpx:0f from avgPrcAnaly where pos=0f

/tran=`Buy & pos < 0
/update avgpx:prev avgpx from trade /something like this
/tran=`Sell & pos > 0


/caculates when avgpx changes; (tran=`Buy & pos < 0) or (tran=`Sell & pos > 0)
update avgpx:((prev avgpx)*abs(prev pos)+ prc * abs trd)% abs pos from trade where tran=`Buy, pos > 0f
update avgpx:((prev avgpx)*abs(prev pos)+ prc * abs trd)% abs pos from trade where tran=`Sell, pos < 0f




example:("SJFJFFFF";enlist",") 0: hsym `$getenv[`AX_WORKSPACE],"/Data/example.csv"


/Average price of bought 
example1:update BotAvgPx1:(sums Price*abs(FillQty))%sums abs(FillQty) from example where Trade=`Buy
/Average price of sold
example1:update SoldAvgPx1:(sums Price*abs(FillQty))%sums abs(FillQty) from example1 where Trade=`Sell
example1:update BotAvgPx1:0f, SoldAvgPx1:0f from example1 where i=0
example1:fills example1

// example[`Price]*deltas example[`Position]

example1:update Trade=`Buy,FillQty:200, Price:30f from example1 where Trade

update Total_cost:(deltas Position)*Price from example1 where Trade=`Buy

exec (deltas Position)*Price from example1 where Trade=`Buy
update dfd:sums (FillQty * Price) by Trade from example1

fd:(example[`Trade`FillQty`Price`Position]) / ,enlist 110110b
ffd:flip fd

fdd:();ct:0;tct:0;

bdd:{[Trade;FillQty;Price;Position]
    while[tct<6;
        if[`Overnight~Trade[ct];fdd,:Price[ct]*FillQty[ct]];
        if[`Overnight~Trade[ct-1];fdd,:fdd[ct-1]+Price[ct]*(Position[ct]-Position[ct-1])];
        if[(Trade[ct-1] in `Buy`Sell)&(not Trade[ct]~Trade[ct-1]);fdd,:fdd[ct-1]];
        if[(Trade[ct]~Trade[ct-1])&((0<Position[ct-1])&(0>Position[ct]));fdd,:Price[ct]*Position[ct]];
        if[(`Sell~Trade[ct]) and (Trade[ct]~Trade[ct-1]) and ((0>Position[ct-1]) and (0>Position[ct])) and (not 0~Position[ct]);
            fdd,:fdd[ct-1]+ -1 * Price[ct]*FillQty[ct]];
//         if[-700~Position[ct];
//             fdd,:fdd[ct-1]+ -1 * Price[ct]*FillQty[ct]];
        if[0~Position[ct];fdd,:0f];
    
        tct+:1;
        ct+:1;
        ]
    }

bdd[fd[0];fd[1];fd[2];fd[3]]
fdd
example


q)r:1 1
q)x:0

while[x<10;
    if[1~x mod 2;r,:56];
    if[0~x mod 2;r,:sum -2#r];
    
    x+:1]

r

while[x-:1;r,:sum -2#r]

q)r
1 1 2 3 5 8 13 21 34 55 89

3 mod 2


price:18.54 18.53 18.53 18.52 18.57 18.9 18.9 18.77 18.59 18.51 18.37

{1_x}\[8;price]

3#'{1_x}\[8;price]

{1 rotate x}\[8;price]

3#'{1 rotate x}\[8;price]5

count price
er:0
r:1 1


while[er<11;if[18.5>price[er];r,:price[er];er+:1]]


bddf[price]
        
        
        
        
        
        
        
