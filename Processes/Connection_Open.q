connections:([handle:()];time:();user:();IP:();state:()) //keyed table
connections:([]handle:();time:();user:();IP:();state:()) //unkeyed table (unkeyed table is better)


.z.po:{[h]
    -1 string[.z.p],"| Connection opened by : ",string h;
    `connections insert (h;.z.p;.z.u;.z.a;`open);  //h:.z.w
    0N!(h;.z.p;.z.u;.z.a;`open);} //handle;time;Username;IP;state
