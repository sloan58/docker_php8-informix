<?php
$hostname = '192.168.1.122';
$database = 'UnityDirDB';
$login = 'Administrator';
$password = 'A$h8urn!';
$informixserver = 'ciscounity';
$dbh = new PDO("informix:host=$hostname;service=20532;database=$database;server=$informixserver; protocol=onsoctcp; DB_LOCALE=en_us.utf8; CLIENT_LOCALE=en_us.utf8;", $login, $password);
#Set the database handle to return all column names as lowercase
$dbh->setAttribute(PDO::ATTR_CASE, PDO::CASE_LOWER);
?>
