// Split the following vector up into 4 groups where the sum of each group is as homogeneous as possible.

splitToHomogeneousGroups: { 
    / Initialize 4 groups; Initialize sums for each group
    / Note they are defined as global as they need to be accessed within a function as well.
    groups:: (();();();()); sumGroup:: 0 0 0 0;
    
    / Distribute elements to the groups
    {
        / Find the index of the group with the minimum sum
        idx: sumGroup? min sumGroup;
        
        / Add the element to the chosen group
        groups[idx]: groups[idx], x;
        
        / Update the sum of the chosen group
        sumGroup[idx]: sumGroup[idx] + x;
    } each x;
    
    / Return the groups
    groups
 };

/ Sample vector
vector: 100 200 300 400 500 600 700 800 900 1000j;
x: 10000 2006 300 400 500 600 700 800 900 1000;
y: 100?999999


/ Run the function
splitToHomogeneousGroups vector
splitToHomogeneousGroups x
splitToHomogeneousGroups y
deltas sum each splitToHomogeneousGroups y