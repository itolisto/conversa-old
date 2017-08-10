DROP PROCEDURE IF EXISTS `SP_UPD_ADMIN_TOKEN`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_ADMIN_TOKEN`(IN `i_id` 		   INT UNSIGNED,
															     IN `i_token` 	   VARCHAR(100) CHARSET utf8,
															     IN `i_last_login` INT UNSIGNED,
															     OUT `o_result`    TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET o_result = 3;
		SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
	END;


	IF (SELECT 1 = 1 FROM `co_admins` WHERE `ad_id` = i_id) THEN
		UPDATE `co_admins`
		SET    `ad_token` 		= i_token,
			   `ad_last_login` 	= i_last_login
		WHERE  `ad_id` = i_id;

		SET o_result = 1;
	ELSE
		SET o_result = 2;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;