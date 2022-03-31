<?php
include "db.php"; # Executes db.php so $dbh will now be set.
#Create a string with the statement we want.
$sqlline = "select objectid from tbl_Alias";
#Prepare the statement, set it to the $sth variable.
$sth = $dbh->prepare($sqlline);
#Execute the statement
$sth->execute();
#Simple fetch of the next row on the cursor as an object.
$row = $sth->fetch(PDO::FETCH_OBJ);
var_dump($row->objectid);
#close statement handle
$sth->closeCursor();
?>
