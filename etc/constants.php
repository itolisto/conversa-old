<?php
/* FROM EMAIL */
define("EMAIL_METHOD_NOTSEND",0); 
define("EMAIL_METHOD_LOCALSMTP",1); 
define("EMAIL_METHOD_GMAIL",2); 
/* USER TYPES */
define("BUSINESS_TYPE", 1);
define("USER_TYPE", 2);
/* ERRORS */
define("BLOCK", 10);
define("ERROR", "error");
define("MESSAGE", "message");
define("NOT_EXITS", "invalid");
/* FILES TOKEN LENGTH */
define("FILES_TOKEN_LENGTH", 155);
define("THUMB_FILES_TOKEN_LENGTH", 149);
/* USER/BUSINESS TOKEN LENGTH */
define("USER_TOKEN_LENGTH",  100);
/* PASSWORD RESET TOKEN LENGTH */
define("PASSRESET_TOKEN_LENGTH",  90);
define('PW_RESET_CODE_VALID_TIME',60*5);
/* MESSAGE TYPES */
define('MTEXT_TYPE',1);
define('MIMAGE_TYPE',2);
define('MLOCATION_TYPE',3);
/* UPLOAD TYPE RUTE */
define('UTR_BUSINESS',1);
define('UTR_USER',2);
define('UTR_EMOTICON',3);
define('UTR_CATEGORY',4);
/* FOLDER NAME HIDDEN */
define('CONST_FOLDER_BUSINESS',"bPoqwemT2xAp");
define('CONST_FOLDER_USER',"QUsVPBx5SzVS");
define('CONST_FOLDER_EMOTICON',"mGB78YwAeZ");
define('CONST_FOLDER_CATEGORY',"bU8zpkhmMoKn");
define('CONST_FOLDER_IMAGES',"E0g0zfGqox0p");