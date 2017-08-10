/*
 * METODO QUE LO LLAMA: doConversaAuth, doConversaBusinessAuth
 */
DROP PROCEDURE IF EXISTS `SP_CONVERSA_AUTH`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_CONVERSA_AUTH`(IN `i_type`      TINYINT UNSIGNED,
                                                               IN `i_email`     VARCHAR(255) CHARSET utf8,
                                                               IN `i_password`  VARCHAR(32)  CHARSET utf8,
                                                               OUT `o_result`   TINYINT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE x TINYINT;
    SET x = FT_IS_IN_BLACKLIST(i_email);

    IF x = 0 THEN
        # Business type
        IF i_type = 1 THEN
            SELECT `bu_id` INTO o_result FROM `co_business` USE INDEX(BU_AUTH_IDX) WHERE `bu_email` = i_email AND `bu_password` = i_password;

            IF (o_result IS NULL) THEN
                SET o_result = 0;
            END IF;
        ELSE
            # User type
            IF i_type = 2 THEN
                SELECT `us_id` INTO o_result FROM `co_user` USE INDEX(US_AUTH_IDX) WHERE `us_email` = i_email AND `us_password` = i_password;

                IF (o_result IS NULL) THEN
                    SET o_result = 0;
                END IF;
            ELSE
                # No valid type
                SET o_result = 0;
            END IF;
        END IF;
    ELSE
        # CANT INITIATE SESSION BECAUSE IS ON BLACKLIST
        SET o_result = 0;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;