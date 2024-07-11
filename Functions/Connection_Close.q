connections:([handle:()];time:();user:();IP:();state:()) //keyed table
connections:([]handle:();time:();user:();IP:();state:()) //unkeyed table (unkeyed table is better)


.z.pc:{[h]
    -1 string[.z.p],"| Connection closed by : ",string h;
    `connections upsert `handle`time`user`IP`state!(h;.z.p;.z.u;.z.a;`close);
    0N!(h;.z.p;.z.u;.z.a;`close);} //handle;time;Username;IP;state
