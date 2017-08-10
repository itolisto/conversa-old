DROP PROCEDURE IF EXISTS `SP_UPD_PASSWORD`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_PASSWORD`(IN `i_user_id`  INT UNSIGNED,
														  	  IN `i_new_pass` VARCHAR(110) CHARSET utf8,
                                                              OUT `o_result`  TINYINT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_user` WHERE `us_id` = i_user_id) THEN
        UPDATE `co_user`
        SET    `us_password` = i_new_pass
        WHERE  `us_id`       = i_user_id;

        IF (SELECT 1 = 1 FROM `co_password_change_request` WHERE `psr_valid` = 1 AND `psr_user_id` = i_user_id LIMIT 1) THEN
            UPDATE `co_password_change_request`
            SET    `psr_valid`   = 0
            WHERE  `psr_user_id` = i_user_id;

            SET o_result = 1;
        ELSE
            # Se actualizo password pero hubo un error al actualizar la peticion de reset
            SET o_result = 2;
        END IF;
    ELSE
        IF (SELECT 1 = 1 FROM `co_password_change_request` WHERE `psr_valid` = 1 AND `psr_user_id` = i_user_id LIMIT 1) THEN
            UPDATE `co_password_change_request`
            SET    `psr_valid`   = 0
            WHERE  `psr_user_id` = i_user_id;

            SET o_result = 3;
        ELSE
            # No actualizo password y hubo un error al actualizar la peticion de reset
            SET o_result = 4;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;