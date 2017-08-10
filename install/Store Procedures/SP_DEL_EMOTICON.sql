DROP PROCEDURE IF EXISTS `SP_DEL_EMOTICON`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_EMOTICON`(IN `i_id`	INT UNSIGNED, OUT `o_result` TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET o_result = 0;
		SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
	END;

	IF (SELECT 1 = 1 FROM `co_emoticon` WHERE `em_id` = i_id) THEN
		DELETE FROM `co_emoticon`
		WHERE `em_id` = i_id;
		# REGRESAR VALOR DE EXITO
		SET o_result = 1;
	ELSE
		# REGRESAR VALOR DE EXITO PORQUE YA NO EXISTE
		SET o_result = 2;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;