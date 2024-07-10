activitySelection: {
    / Sort activities by their end times
    sorted: x iasc x[;1;1];
    
    / Initialize the first activity as selected
    selected:: enlist first sorted;
    
    / Iterate through the sorted activities and select non-overlapping ones
    {
        / Check if the start time is greater than or equal to the end time of the last selected activity
        if[x[0] >= last selected[;1]; selected,: enlist x]
    } each 1_ sorted;
    
    selected
 };

/ Example usage
activities: (("A";1 2);("B";3 4);("C";0 6);("D";5 7);("E";8 9);("F";5 9));
x:(("A";1 2);("B";3 4);("C";0 6);("D";5 7);("E";8 9);("F";5 9));
activitySelection activities

x iasc x[;1;1]
x[1]