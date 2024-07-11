// Concatenating two columns of a table in select

tab:([]firstname:`John`Jia`Jai`Jac;lastname:`James`Jain`Jadeja`Jones;age:1+4?30)

// a) Two columns as lists
// q)
// name
// ----------
// John James
// Jia  Jain
// Jai  Jadeja
// Jac  Jones

ans:
select name:(firstname,'lastname) from tab


// b) Two columns as String
// Join them as string (Citadel)
// fullname     age
// ----------------
// "John James" 13
// "Jia Jain"   9
// "Jai Jadeja" 11
// "Jac Jones"  2


ans:
select fullname: ((string firstname),'" " ,'(string lastname)), age from tab


// c) Two columns as String
// A mixed list is formed if the columns are of different type. If you cast the columns to string before each-both join, a concatenated string is formed. You can also insert a character using ,'.
// col
// --------------
// "JohnJames/19"
// "JiaJain/24"
// "JaiJadeja/25"
// "JacJones/19


// ans:
select col:((string firstname),'(string lastname),'"/",'(string age)) from tab
// If you need multi character delimiters, use sv. 
// A nice advantage of this method is you don’t have to individually convert each column to string.

// d)
// col
// -----------------
// "John--James--19"
// "Jia--Jain--24"
// "Jai--Jadeja--25"
// "Jac--Jones--19"

ans:
select col:({"--" sv x} each string (firstname,'lastname,'age)) from tab


// e) Make the table like the below
// firstname lastname age Dear
// ----------------------------------
// John      James    13  "Dear John"
// Jia       Jain     9   "Dear Jia"
// Jai       Jadeja   11  "Dear Jai"
// Jac       Jones    2   "Dear Jac"

// ans:
// To add a string as prefix and postfix to a column, you can use /:(each right) and \:(each left) respectively.
update Dear:("Dear ",/: string firstname) from `tab


// f) Split a column into two (dear & name)
// q)
// dear name
// ---------
// Dear John
// Dear Jia
// Dear Jai
// Dear Jac


// ans:
// Using select
select dear:"S"$4#'Dear, name:"S"$5_'Dear from tab

// Using exec
flip exec `dear`name!"SS"$(5#;4_)@/:\: Dear from tab
flip exec `dear`name!"SS"$(#[5];_[4])@/:\: Dear from tab
