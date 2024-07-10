binarySearch: {
    / x is the sorted list, y is the target value
    low::0;
    high:: (count x) - 1;
    
    while[low <= high; {
        mid: low + floor (high - low) % 2;
        if[x[mid] = y; : mid];
        if[x[mid] < y; low: mid + 1; high: mid - 1];
    }];
    
    -1  / return -1 if not found
    };

/ Example usage
sortedList: 1 3 5 7 9 11 13 15 17 19;
target: 7;
binarySearch[sortedList; target]

sortedList((count sortedList)-1)
