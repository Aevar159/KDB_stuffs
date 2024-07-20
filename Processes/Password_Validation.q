h"users:([user:`mary`john`ann ] password:(\"pwd\";\"pwd\";\"pwd\"))"
.perm.users:([user:`mary`john`ann ] password:("pwd";"pwd";"pwd"))


.z.pw:{[user;pswd] $[pswd~.perm.users[user][`password]; 1b; 0b]}


q)h:hopen `::5000:mary:pwd
q)h:hopen `::5000:mary:pwd2
'access
  [0]  h:hopen `::5000:mary:pwd2
         ^
