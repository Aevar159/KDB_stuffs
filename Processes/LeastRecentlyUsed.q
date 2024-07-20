// Code: https://bitbucket.org/alvikabir/dailyq/src/master/Advanced/lru-query-cache


cache:([]date:();sym:();data:());
CACHE_SIZE:2;
.z.pg:{
    if[10h=type x;x:parse x];                                       /convert str to parse tree
    wc:raze x[2];                                                   /where clause
    dt:wc[0;2];                                                     /date value
    s:wc[1;2];                                                      /sym value
    if[not `date`sym~2#wc[;1];'BadQuery];                           /expect date,sym
    if[not (1=count s) & 1=count dt;'BadQuery];                     /expect 1 date, 1 sym
    //try extracting data from cache with given date and sym
    data:exec data from cache where date=dt, sym=first s;
    /if there is none from cache select it otherwise select from the disk
    data:reval $[count data; data; (?;x[1];enlist 2#wc;0b;())];     /initial select for date+sym data
    delete from `cache where date=dt, sym=first s;                  /Delete the cache entry if it exists
    `cache insert (dt;first s;data);                                /insert the selected data
    cache::-1 rotate cache;                                         /place data at head of cache
    if[CACHE_SIZE<count cache; cache::-1_cache];                    /drop least recent
    
    /Select from the data using the remaining where clause filters, group by expression, and column selection.
    reval (?;data;enlist 2_wc;x[3];x[4])                            
 };