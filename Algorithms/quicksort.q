// Best quicksort solution on the web
q:{$[2>distinct count x;x;raze q each x where each (not \) x < rand x]};

x:10 80 30 90 40 50 70;

q[x]


/ QuickSort function in standard way that I wrote
quickSort: {
    / Base case: if the list has one or zero elements, it's already sorted
    if[2>count x;:x];
    
    / Choose the pivot (here we choose the first element)
    pivot: first x;
    
    / Partition the list into elements less than, equal to, and greater than the pivot
    less: x where x < pivot;
    equal: x where x = pivot;
    greater: x where x > pivot;
    
    / Recursively sort the partitions and concatenate the results
    (.z.s less), equal, (.z.s greater)
    };

/ Example usage
unsortedList: 5 3 8 4 2 7 1 6;
quickSort unsortedList;
