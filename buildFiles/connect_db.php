<?php
include "db.php";
$sqlline = "select first 10 objectid from tbl_Alias";
$sth = $dbh->prepare($sqlline);
$sth->execute();
while (($row = $sth->fetch(PDO::FETCH_OBJ)) != null) {
    var_dump($row->objectid);
}
$sth->closeCursor();
