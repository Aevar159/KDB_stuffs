//adds the query statements to queryLog 
.z.ps:{[query] `queryLog upsert(.z.u;.z.p;.Q.s1 query;1b); value query} /.Q.s1 to format query

//default definition of .z.ps
.z.ps:{[query] value query}

//make this as read only
.z.ps:{[query] reval (value; enlist query)}
