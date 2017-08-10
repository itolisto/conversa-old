DROP PROCEDURE IF EXISTS `SP_INS_PASSWORD_RESET_REQUEST`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_PASSWORD_RESET_REQUEST`(IN `i_id`       INT UNSIGNED,
                                                                            IN `i_token`    VARCHAR(90) CHARSET utf8,
                                                                            IN `i_created`  INT UNSIGNED,
                                                                            OUT `o_result`  TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_password_change_request` WHERE `psr_user_id` = i_id AND `psr_valid` = 1 LIMIT 1) THEN
        UPDATE `co_password_change_request`
        SET `psr_token`   = i_token,
            `psr_created` = i_created
        WHERE `psr_user_id` = i_id;

        SET `o_result` = 2;
    ELSE
        INSERT INTO `co_password_change_request` (
          `psr_user_id`,
          `psr_token`,
          `psr_created`)
        VALUES (
          i_id,
          i_token,
          i_created);

        SET `o_result` = 1;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;