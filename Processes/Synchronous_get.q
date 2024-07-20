//adds the query statements to queryLog 
.z.pg:{[query] `queryLog upsert(.z.u;.z.p;.Q.s1 query;1b); value query} /.Q.s1 to format query

//default definition of .z.pg
.z.pg:{[query] value query}

//make this as read only
.z.pg:{[query] reval (value; enlist query)}
