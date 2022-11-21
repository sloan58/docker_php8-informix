<?php

$hostname = '10.1.10.1';
$database = 'UnityDirDB';
$login = 'Administrator';
$password = 'Password';
$informixserver = 'ciscounity';
$dbh = new PDO("informix:host=$hostname;service=20532;database=$database;server=$informixserver;protocol=onsoctcp;DB_LOCALE=en_us.utf8;CLIENT_LOCALE=en_us.utf8;", $login, $password);
$dbh->setAttribute(PDO::ATTR_CASE, PDO::CASE_LOWER);
