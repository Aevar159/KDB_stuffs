// Server 
\p 5000i //First listen to a port

worker:{[arg;callback] 
    0N!.z.w; neg[.z.w] (callback;0N!3*arg)}
//.z.w gives the handle of the B


// Client Process 
h:hopen 5000 //Now connect to that port

continue:{0N!.z.w;0N!x;0N!`done} //prints (handle of the B;result;`done)
(neg h) (`worker;5;`continue)
