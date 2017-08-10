DROP PROCEDURE IF EXISTS `SP_DEL_SERVER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_SERVER`(IN `i_id` TINYINT UNSIGNED, OUT `o_result` TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER

BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET o_result = 3;
		SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
	END;

	IF (SELECT 1 = 1 FROM `co_servers` WHERE `se_id` = i_id) THEN
		DELETE FROM `co_servers`
		WHERE `se_id` = i_id;
		# Regresar valor de exito
		SET o_result = 1;
	ELSE
		# Regresar valor de exito pero no se elimino nada
		SET o_result = 2;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;