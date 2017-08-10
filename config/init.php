<?php

/*
 * This file is part of the Silex framework.
 *
 * Copyright (c) 2013 clover studio official account
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
*/
 
 
/* change here */
define('ROOT_URL','http://localhost/Server/wwwroot');
define('LOCAL_ROOT_URL', 'http://localhost/Server/wwwroot');

define("MySQL_HOST", 'localhost');
define('MySQL_DBNAME', 'conversadb');
define('MySQL_USERNAME', 'root');
define('MySQL_PASSWORD', 'GaQhikhPoBB0f');
/* end change here */

define('ENABLE_LOGGING',false);

define('SUPPORT_USER_ID', 1);
define('ADMIN_LISTCOUNT', 10);
define("DEFAULT_LANGUAGE","en");

define("DIRECTMESSAGE_NOTIFICATION_MESSAGE", "You got message from %s");
define("DIRECTMESSAGE_NOTIFICATION_READ", true);

define("APN_DEV_CERT_PATH", "files/apns-dev.pem");
define("APN_PROD_CERT_PATH", "files/apns-prod.pem");
define("GCM_API_KEY","AIzaSyB20NyCcjv6ZY0RHdrw8a1hqOXwCZn3qs8");

define("SEND_EMAIL_METHOD",2); // 0: dont send 1:local smtp 2:gmail
define('EMAIL_LOCAL', "admin@appconversa.com");
define('EMAIL_GMAIL', "appconversa@gmail.com");
define("GMAIL_PASSWORD","GaQhikhPoBB0f");