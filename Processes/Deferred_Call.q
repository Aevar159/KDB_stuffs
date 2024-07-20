// Target Process
\p 5000

// Client Process
h:hopen 5000
h({neg[.z.w] show `messageReceived; -30!(::)};1+1)

// Target Process
-30!(first key .z.W;0b;2)

// Client Process
/ Will get the query value which is 2
q)h({neg[.z.w] show `msgReceived; -30!(::)};1+1)
2


// Use -30!(::) at any place in the execution path of .z.pg.
.z.pg:{[query]
    remoteFunction:{[clntHandle;query]
        neg[.z.w](`callback;clntHandle;@[(0b;)value@;query;{[errorString](1b;errorString)}])};
    neg[workerHandles]@\:(remoteFunction;.z.w;query); / send the query to each worker
    -30!(::); / defer sending a response message i.e. return value of .z.pg is ignored}
