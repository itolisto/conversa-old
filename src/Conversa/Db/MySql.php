<?php
/*
 * This file is part of the Silex framework.
 *
 * Copyright (c) 2013 clover studio official account
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
namespace Conversa\Db;

use Conversa\Db\DbInterface;
use Psr\Log\LoggerInterface;
use Doctrine\DBAL\Connection;
use PDO;

class MySQL implements DbInterface {
    
    private $logger;
    private $DB;

    public function __construct(LoggerInterface $logger,Connection $DB){
        $this->logger     = $logger;
        $this->DB         = $DB;
    }
    
    /**********************************************************************************************/
    /**********************************************************************************************/
    /*****************************************AUTH METHODS*****************************************/
    /**********************************************************************************************/
    /**********************************************************************************************/
    
    /**
     * Valida el ingreso al dashboard de administradores
     * 
     * @param string $email Submitted email
     * @param string $password Submitted password
     * @return array with admin data. If no admin is found an array with error message.
     */
    public function doConversaAdminAuth($email,$password) {
        //$user = $this->DB->fetchAssoc('SELECT * FROM admins WHERE email = ? AND password = ?', array($email, $password));

        $sentencia = $this->DB->prepare("CALL SP_CONAUTH_ADMINS(?,?,?,@valor)");
        $sentencia->bindValue(1, 1,          PDO::PARAM_INT);
        $sentencia->bindParam(2, $email,     PDO::PARAM_STR);
        $sentencia->bindParam(3, $password,  PDO::PARAM_STR);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @valor AS resultado")->fetch(PDO::FETCH_ASSOC);
        $userId = intval($result['resultado'],10);

        if($userId != 0) {
            $token     = \Conversa\Utils::randString(USER_TOKEN_LENGTH, USER_TOKEN_LENGTH);
            $sentencia = $this->DB->prepare("CALL SP_UPD_ADMIN_TOKEN(?,?,?,@result)");
            $sentencia->bindParam(1, $userId, PDO::PARAM_INT);
            $sentencia->bindParam(2, $token,  PDO::PARAM_STR);
            $sentencia->bindValue(3, time(),  PDO::PARAM_INT);
            $sentencia->execute();
            $sentencia->closeCursor();
            $receive = $this->DB->query("SELECT @valor AS resultado")->fetch(PDO::FETCH_ASSOC);
            $code = intval($receive['resultado'],10);
        
            if($code == 1) {
                $admin = $this->findAdminById($userId);
                $admin['token'] = $token;
                return $admin;
            } else {
                return null;
            }
        } else {
            return null;
        }
    }
    
    
    /**
     * Valida el ingreso a la aplicacion de usuarios
     * 
     * @param string $email Email ingresado en la aplicación.
     * @param string $password Password ingresado en la aplicación.
     * @return array Datos del usuario si no lo encuentra devuelve un array con error.
     */
    public function doConversaAuth($email,$password) {
        $sentencia = $this->DB->prepare("CALL SP_CONVERSA_AUTH(?,?,?,@valor)");
        $user_type = USER_TYPE;
        $sentencia->bindParam(1, $user_type, PDO::PARAM_INT);
        $sentencia->bindParam(2, $email,     PDO::PARAM_STR);
        $sentencia->bindParam(3, $password,  PDO::PARAM_STR);
        // llamar al procedimiento almacenado
        $sentencia->execute();
        //Second, to get the result, we need to query it from the variable @valor. It is important that we must call the
        //method closeCursor() of the PDOStatement object in order to execute the next SQL statement.
        $sentencia->closeCursor();
        //Get result
        $result = $this->DB->query("SELECT @valor AS resultado")->fetch(PDO::FETCH_ASSOC);
        $userId = intval($result['resultado'], 10);
        
        if($userId != 0) {
            $token      = \Conversa\Utils::randString(USER_TOKEN_LENGTH, USER_TOKEN_LENGTH);

            $sentencia = $this->DB->prepare("CALL SP_UPD_USER_TOKEN(?,?,?)");
            $sentencia->bindParam(1, $userId, PDO::PARAM_INT);
            $sentencia->bindParam(2, $token,  PDO::PARAM_STR);
            $sentencia->bindValue(3, time(),  PDO::PARAM_INT);
            $sentencia->execute();
            $sentencia->closeCursor();

            $sentencia = $this->DB->prepare("CALL SP_SEL_USER_BY_ID(?,?)");
            $sentencia->bindValue(1, 0,       PDO::PARAM_INT);
            $sentencia->bindParam(2, $userId, PDO::PARAM_INT);
            $sentencia->execute();
            $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
            $sentencia->closeCursor();
            if(!empty($result)) {
                $userFound = $result[0];
            } else {
                $userFound = null;
            }

            return $userFound;   
        } else {
            return null;
        }
    }
    
    /**
     * Valida el ingreso a la aplicacion de negocio
     * 
     * @param string $email Submitted email
     * @param string $password Submitted password
     * @return array with user data. If no user is found an array with error message.
     */
    public function doConversaBusinessAuth($email,$password,$os) {
        $sentencia = $this->DB->prepare("CALL SP_CONVERSA_AUTH(?,?,?,@valor)");
        $user_type = BUSINESS_TYPE;
        $sentencia->bindParam(1, $user_type, PDO::PARAM_INT);
        $sentencia->bindParam(2, $email,     PDO::PARAM_STR);
        $sentencia->bindParam(3, $password,  PDO::PARAM_STR);
        $sentencia->execute();
        $sentencia->closeCursor();
        //Get result
        $result = $this->DB->query("SELECT @valor AS resultado")->fetch(PDO::FETCH_ASSOC);
        $businessId = intval($result['resultado'], 10);
        
        if($businessId != 0) {
            $token     = \Conversa\Utils::randString(USER_TOKEN_LENGTH, USER_TOKEN_LENGTH);
            $sentencia = $this->DB->prepare("CALL SP_SELINS_BUS_DEVICE(?,?,?,?,@result)");
            $sentencia->bindParam(1, $businessId, PDO::PARAM_INT);
            $sentencia->bindParam(2, $token,      PDO::PARAM_STR);
            $sentencia->bindValue(3, time(),      PDO::PARAM_INT);
            $sentencia->bindParam(4, $os,         PDO::PARAM_INT);
            $sentencia->execute();
            $sentencia->closeCursor();
            $active_devices = $this->DB->query("SELECT @result AS result")->fetch(PDO::FETCH_ASSOC);
            // Register process result
            $login = intval($active_devices['result'], 10);

            if($login != 0) {
                $sentencia = $this->DB->prepare("CALL SP_SEL_BUS_BY_ID(?)");
                $sentencia->bindParam(1, $businessId, PDO::PARAM_INT);
                $sentencia->execute();
                $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
                $sentencia->closeCursor();
                if(!empty($result)) {
                    $userFound = $result[0];
                    $userFound['token'] = $token;
                    return $userFound;
                } else {
                    return null;
                }
            } else {
                return null;
            }
        } else {
            return null;
        }
    }
    
    /**********************************************************************************************/
    /**********************************************************************************************/
    /***************************************CONTACTS METHODS***************************************/
    /**********************************************************************************************/
    /**********************************************************************************************/
    /**
     * Encuentra todos los contactos por <b>id</b>
     * 
     * @param string $id Se busca para este parámetro.
     * @param string $user_type El tipo de usuario que realiza la búsqueda.<br>
     *                          Valor por defecto es la constante <i>USER_TYPE</i>.
     * @param string $token Se especifica el <b>token</b> cuando se realiza<br>
     *                      la búsqueda para un <b>negocio</b>.
     * @return array <b>id's</b> asociados a un tipo de usuario.
     */
    public function findContactsById($id,$user_type = USER_TYPE,$token = '') {
        $sentencia = $this->DB->prepare("CALL SP_SEL_USBU_CONTACTS_BY_ID(?,?,?)");
        $sentencia->bindParam(1, $user_type,  PDO::PARAM_INT);
        $sentencia->bindParam(2, $id,         PDO::PARAM_INT);
        $sentencia->bindParam(3, $token,      PDO::PARAM_STR);
        $sentencia->execute();
        try {
            $contacts  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        } catch (\Exception $e) {
            $contacts  = $e;
        }
        $sentencia->closeCursor();
        $contactIds = array();
        
        if(is_array($contacts)){
            foreach($contacts as $row){
                if ($row['contact_u'] != 0) {
                    $key['user']  = $row['contact_u'];
                    $contactIds[] = $key;
                } else {
                    if ($row['contact_b'] != 0) {
                        $key['business'] = $row['contact_b'];
                        $contactIds[]    = $key;
                    }
                }
                unset($key);
            }
        }
        $data['contacts'] = $contactIds;
        return $data;
    }
    
    /**
     * Agrega un negocio como un contacto para un usuario. Si el negocio no tiene al usuario como<br></br>
     * contacto, este tambien se agrega para el negocio.
     * 
     * @param int $userId
     * @param int $targetId
     * @return int
     */
    public function addContact($userId,$targetId) {
        $sentencia = $this->DB->prepare("CALL SP_INS_USER_CONTACT(?,?,?,?,?,@valor)");
        $sentencia->bindParam(1, $userId,       PDO::PARAM_INT);
        $sentencia->bindParam(2, $targetId,     PDO::PARAM_INT);
        $sentencia->bindValue(3, time(),        PDO::PARAM_INT);
        $sentencia->bindValue(4, USER_TYPE,     PDO::PARAM_INT);
        $sentencia->bindValue(5, BUSINESS_TYPE, PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @valor AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10); 

        if($code == 0 || $code == 1) {
            // Ya era contacto
            return 1;
        } else {
            if($code == 2) {
                // Bloqueado
                return 2;
            } else {
                // Error
                return 3;
            }
        }
    }
    
    //TODO: Implementar negocio a negocio
    /**
     * Agrega un usuario como un contacto para un negocio. Si el usuario no tiene al negocio como<br></br>
     * contacto, este tambien se agrega para el usuario.
     * 
     * @param type $userId
     * @param type $targetId
     * @param type $pushId
     * @param type $type
     * @return boolean
     */
    public function addContactBusiness($userId,$targetId,$pushId) {
        $sentencia = $this->DB->prepare("CALL SP_INS_BUS_CONTACT(?,?,?,?,?,?,@valor)");
        $sentencia->bindParam(1, $userId,       PDO::PARAM_INT);
        $sentencia->bindParam(2, $targetId,     PDO::PARAM_INT);
        $sentencia->bindParam(3, $pushId,       PDO::PARAM_INT);
        $sentencia->bindValue(4, time(),        PDO::PARAM_INT);
        $sentencia->bindValue(5, BUSINESS_TYPE, PDO::PARAM_INT);
        $sentencia->bindValue(6, USER_TYPE,     PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @valor AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10); 

        if($code == 0) {
            return 1;
        } else {
            if($code == 1) {
                return 1;
            } else {
                if($code == 2) {
                    //BLOQUEADO
                    return 2;
                } else {
                    return 3;
                }
            }
        }
    }
    
    /**
     * Remueve un contacto para un usuario.
     * 
     * @param type $userId
     * @param type $targetId
     * @return boolean
     */
    public function removeContact($userId,$targetId) {
        $sentencia = $this->DB->prepare("CALL SP_UPD_USER_CONTACT(?,?,@valor)");
        $sentencia->bindParam(1, $userId,   PDO::PARAM_INT);
        $sentencia->bindParam(2, $targetId, PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @valor AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10); 

        if($code == 1) {
            //Se actualizo a invalido
            return 1;
        } else {
            if($code == 2) {
                //No existe contacto
                return 1;
            } else {
                //Error
                return 0;
            }
        }
    }
    
    /**
     * Remueve un contacto para un negocio.
     * 
     * @param type $id
     * @param type $targetId
     * @param type $pushId
     * @return boolean
     */
    public function removeContactBusiness($id,$targetId,$pushId) {
        $sentencia = $this->DB->prepare("CALL SP_UPD_BUS_CONTACT(?,?,?,@valor)");
        $sentencia->bindParam(1, $id,       PDO::PARAM_INT);
        $sentencia->bindParam(2, $targetId, PDO::PARAM_INT);
        $sentencia->bindParam(3, $pushId,   PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @valor AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10); 

        if($code == 1) {
            //Se actualizo a invalido
            return 1;
        } else {
            if($code == 2) {
                //No existe contacto
                return 1;
            } else {
                //Error
                return 0;
            }
        }
    }
    
    /**
     * Bloquea un contacto para un negocio o usuario.
     * 
     * @param type $id
     * @param type $targetId
     * @param type $type
     * @param type $targetType
     * @param type $action
     * @return boolean
     */
    public function blockContact($id,$targetId,$type,$targetType,$action) {
        $sentencia = $this->DB->prepare("CALL SP_UPDINS_BLOCK_CONTACT(?,?,?,?,?,?,@valor)");
        $sentencia->bindParam(1, $id,         PDO::PARAM_INT);
        $sentencia->bindParam(2, $targetId,   PDO::PARAM_INT);
        $sentencia->bindParam(3, $type,       PDO::PARAM_INT);
        $sentencia->bindParam(4, $targetType, PDO::PARAM_INT);
        $sentencia->bindParam(5, $action,     PDO::PARAM_INT);
        $sentencia->bindValue(6, time(),      PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @valor AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10);
        if($code == 1) {
            //Accion realizada con exito
            return 1;
        } else {
            if($code == 2) {
                //Ya estaba realizada la accion y no hubo error
                return 1;
            } else {
                //Error
                return 0;
            }
        }
    }
    
    /**
     * Agrega negocio como favorito para usuario.
     * 
     * @param type $userId
     * @param type $targetUserId
     * @return boolean
     */
    public function addRemoveFavorite($userId,$targetId,$action) {
        $sentencia = $this->DB->prepare("CALL SP_UPDINS_FAVORITE(?,?,?,?,@valor)");
        $sentencia->bindParam(1, $userId,   PDO::PARAM_INT);
        $sentencia->bindParam(2, $targetId, PDO::PARAM_INT);
        $sentencia->bindParam(3, $action,   PDO::PARAM_INT);
        $sentencia->bindValue(4, time(),    PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @valor AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10);
        if($code == 1) {
            //Accion realizada con exito
            return 1;
        } else {
            if($code == 2) {
                //Ya estaba realizada la accion y no hubo error
                return 1;
            } else {
                //Error
                return 0;
            }
        }
    }
    
    /**********************************************************************************************/
    /**********************************************************************************************/
    /***************************************EMOTICONS METHODS**************************************/
    /**********************************************************************************************/
    /**********************************************************************************************/
    public function getEmoticons(){
	$sentencia = $this->DB->prepare("CALL SP_SEL_EMOTICON()");
	$sentencia->execute();
	$emoticons = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();
	return $emoticons;
    }

    public function getEmoticonByName($identifier){
	$sentencia = $this->DB->prepare("CALL SP_SEL_EMOTICON_BY_IDENTIFIER(?)");
	$sentencia->bindParam(1,$identifier,PDO::PARAM_STR);
	$sentencia->execute();
	$result = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();
        if(!empty($result)) {
            return $result[0];
        } else {
            return null;
        }
    }

    public function getEmoticonAvatarById($id){
	$sentencia = $this->DB->prepare("CALL SP_SEL_EMOTICON_AVATAR_BY_ID(?)");
	$sentencia->bindParam(1, $id, PDO::PARAM_INT);
	$sentencia->execute();
	$result = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();
        if(!empty($result)) {
            return $result[0];
        } else {
            return null;
        }
    }
    
    public function createEmoticon($identifier,$picture){
	$sentencia = $this->DB->prepare("CALL SP_INS_EMOTICON(?,?,?,@last)");
	$sentencia->bindParam(1, $identifier,PDO::PARAM_INT);
	$sentencia->bindParam(2, $picture,   PDO::PARAM_STR);
	$sentencia->bindValue(3, time(),     PDO::PARAM_INT);
	$sentencia->execute();
	$sentencia->closeCursor();
        $result = $this->DB->query("SELECT @last AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10); 

        if($code == 1) {
            // Accion realizada con exito
            return 1;
        } else {
            if($code == 2) {
                // Nombre de emoticon ya existe y no se pudo insertar
                return 0;
            } else {
                // Error: No se pudo insertar
                return 0;
            }
        }
    }

    public function findAllEmoticonsWithPaging($count,$offset = 0){
	$sentencia = $this->DB->prepare("CALL SP_SEL_EMOTICON_WITH_PAGING(?,?)");
	$sentencia->bindParam(1, $count,  PDO::PARAM_INT);
	$sentencia->bindParam(2, $offset, PDO::PARAM_INT);
	$sentencia->execute();
	$emoticons = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();
        return $emoticons;
    }
    
    public function findEmoticonCount(){
	$sentencia = $this->DB->prepare("CALL SP_SEL_EMOTICON_COUNT(@count)");
	$sentencia->execute();
	$sentencia->closeCursor();
	$result = $this->DB->query("SELECT @count AS count")->fetch(PDO::FETCH_ASSOC);
        $count = intval($result['count'], 10);
	return $count;
    }

    public function findEmoticonById($id){
	$sentencia = $this->DB->prepare("CALL SP_SEL_EMOTICON_BY_ID(?)");
	$sentencia->bindParam(1, $id, PDO::PARAM_INT);
	$sentencia->execute();
	$result = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();
        if(!empty($result)) {
            return $result[0];
        } else {
            return array();
        }
    }
    
    public function updateEmoticon($id,$title,$picture){
	$sentencia = $this->DB->prepare("SP_UPD_EMOTICON(?,?,?,?,@result)");
	$sentencia->bindParam(1, $id,       PDO::PARAM_INT);
	$sentencia->bindParam(2, $title,    PDO::PARAM_STR);
	$sentencia->bindParam(3, $picture,  PDO::PARAM_STR);
	$sentencia->bindValue(4, time(),    PDO::PARAM_INT);
	$sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @result AS result")->fetch(PDO::FETCH_ASSOC);
        $code   = intval($result['result'], 10);
        if($code == 1) {
            // Accion realizada con exito
            return true;
        } else {
            if($code == 2) {
                // nombre ya existe y no se pudo insertar
                return false;
            } else {
                // Error: No se pudo actualizar
                return false;
            }
        }
    }

    public function deleteEmoticon($id){
        $sentencia = $this->DB->prepare("CALL SP_DEL_EMOTICON(?,@result)");
        $sentencia-bindParam(1,$id,PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @result AS result")->fetch(PDO::FETCH_ASSOC);
        $status = intval($result['result'], 10);
        if($status == 1 || $status == 2) {
            return true;
        } else {
            return false;
        }
    }
    
    /**********************************************************************************************/
    /**********************************************************************************************/
    /***************************************SERVER METHODS*****************************************/
    /**********************************************************************************************/
    /**********************************************************************************************/
    public function findServersCount(){
	$sentencia = $this->DB->prepare("CALL SP_SEL_SERVERS_COUNT(@count)");
	$sentencia->execute();
	$sentencia->closeCursor();
	$result = $this->DB->query("SELECT @count AS count")->fetch(PDO::FETCH_ASSOC);
        $total = intval($result['count'], 10);
	return $total;
    }
    
    public function reformatServerData($server) {
    	$server['se_created']  = intval($server['se_created']);
    	$server['se_modified'] = intval($server['se_modified']);
    	return $server;
    }
    
    public function findAllServersWithPaging($offset=0,$count=0) {
	$result = $this->DB->prepare("CALL SP_SEL_SERVERS_WITH_PAGING(?,?)");
	$result->bindParam(1, $offset, PDO::PARAM_INT);
	$result->bindParam(2, $count,  PDO::PARAM_INT);
	$result->execute();
	$servers = $result->fetchAll(PDO::FETCH_ASSOC);
	$result->closeCursor();
	return $servers;
    }
    
    public function createServer($name,$url) {        
        $sentencia = $this->DB->prepare("CALL SP_INS_SERVER(?,?,?,@last)");
	$sentencia->bindParam(1, $name,  PDO::PARAM_STR);
	$sentencia->bindParam(2, $url,   PDO::PARAM_STR);
	$sentencia->bindValue(3, time(), PDO::PARAM_INT);
	$sentencia->execute();
	$sentencia->closeCursor();
        $result = $this->DB->query("SELECT @last AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10); 

        if($code == 1) {
            // Accion realizada con exito
            return true;
        } else {
            if($code == 2) {
                // Url de server o nombre ya existe y no se pudo insertar
                return false;
            } else {
                // Error: No se pudo insertar
                return false;
            }
        }
    }
    
    public function findServerById($id) {
	$sentencia = $this->DB->prepare("CALL SP_SEL_SERVER_BY_ID(?)");
	$sentencia->bindParam(1, $id, PDO::PARAM_INT);
	$sentencia->execute();
	$result = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();	
	if(!empty($result)) {
            return $result[0];
        } else {
            return array();
        }
    }
    
    public function updateServer($server_id,$name,$url) {	
	$sentencia = $this->DB->prepare("CALL SP_UPD_SERVER(?,?,?,?,@result)");
	$sentencia->bindParam(1, $server_id, PDO::PARAM_INT);
	$sentencia->bindParam(2, $name,      PDO::PARAM_STR);
	$sentencia->bindParam(3, $url,       PDO::PARAM_STR);
	$sentencia->bindValue(4, time(),     PDO::PARAM_INT);
	$sentencia->execute();
	$sentencia->closeCursor();
	$result = $this->DB->query("SELECT @result AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10);
        if($code == 1) {
            // Se actualizo con exito
            return true;
        } else {
            if($code == 2) {
                // No existe registro
                return false;
            } else {
                // Error
                return false;
            }
        }
    }
    
    public function deleteServer($id) {
	$sentencia = $this->DB->prepare("CALL SP_DEL_SERVER(?,@result)");
	$sentencia->bindParam(1, $id, PDO::PARAM_INT);
	$sentencia->execute();
	$sentencia->closeCursor();
	$result = $this->DB->query("SELECT @result AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10);
        if($code == 1 || $code == 2) {
            // Se elimino con exito o no existe registro
            return true;
        } else {
            // Error
            return false;
        }
    }
    
    /**
     * Devuelve la lista de servidores y su url
     * 
     * @return array con el resultado
     */
    public function findAllServersWithoutId() {
	$result = $this->DB->prepare("CALL SP_SEL_ALL_SERVERS_WITHOUT_ID()");
	$result->execute();
	$servers = $result->fetchAll(PDO::FETCH_ASSOC);
	$result->closeCursor();	
	return $servers;
    }
    
    /**********************************************************************************************/
    /**********************************************************************************************/
    /*************************************CATEGORIES METHODS***************************************/
    /**********************************************************************************************/
    /**********************************************************************************************/
    public function getAllCategoryName() {
        $sentencia = $this->DB->prepare("CALL SP_SEL_CATEGORIES_NAME()");
	$sentencia->execute();
	$result = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();	
	return $result;
    }
    
    public function getAllCategories() {
        $sentencia = $this->DB->prepare("CALL SP_SEL_CATEGORIES()");
	$sentencia->execute();
	$result = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();	
	return $result;
    }
    
    /**
     * Busca todos los negocios, en una categoria, para un usuario.
     * Indicando si es favorito o no.
     * 
     * @param type $target
     * @param type $userId
     * @param type $category
     * @return type
     */
    public function searchForBusinessByCategory($target,$userId,$category,$count,$offset) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_SEARCH_BUSINESS_BY_CATEGORY(?,?,?,?,?)");
	$sentencia->bindParam(1, $userId,   PDO::PARAM_INT);
	$sentencia->bindParam(2, $target,   PDO::PARAM_INT);
        $sentencia->bindParam(3, $category, PDO::PARAM_INT);
        $sentencia->bindParam(4, $count,    PDO::PARAM_INT);
        $sentencia->bindParam(5, $offset,   PDO::PARAM_INT);
	$sentencia->execute();
	$result = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();
        $data['business'] = $result;
        return $data;
    }
    
    /**
     * Busca todos los negocios, en todas las categorias, para un usuario.
     * Indicando si es favorito o no.
     * 
     * @param type $target
     * @param type $userId
     * @return type
     */
    public function searchForBusiness($target,$userId,$count,$offset) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_SEARCH_BUSINESS(?,?)");
	$sentencia->bindParam(1, $userId, PDO::PARAM_INT);
	$sentencia->bindParam(2, $target, PDO::PARAM_INT);
        $sentencia->bindParam(3, $count,  PDO::PARAM_INT);
        $sentencia->bindParam(4, $offset, PDO::PARAM_INT);
	$sentencia->execute();
	$result = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();
        $data['business'] = $result;
        return $data;
    }
    
    public function getAllBusinessByCategory($category) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_BUS_BY_CAT(?)");
	$sentencia->bindParam(1, $category, PDO::PARAM_INT);
	$sentencia->execute();
	$result = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();
        $data['business'] = $result;
        return $data;
    }
    
    public function findAllCategoryWithPaging($count,$offset = 0) {
        $result = $this->DB->prepare("CALL SP_SEL_CATEGORIES_WITH_PAGING(?,?)");
	$result->bindParam(1, $offset, PDO::PARAM_INT);
	$result->bindParam(2, $count,  PDO::PARAM_INT);
	$result->execute();
	$categories = $result->fetchAll(PDO::FETCH_ASSOC);
	$result->closeCursor();
	return $categories;
    }
    
    public function findCategoryCount() {
        $sentencia = $this->DB->prepare("CALL SP_SEL_CATEGORY_COUNT(@count)");
	$sentencia->execute();
	$sentencia->closeCursor();
	$result = $this->DB->query("SELECT @count AS count")->fetch(PDO::FETCH_ASSOC);
        $total = intval($result['count'], 10);
	return $total;
    } 
    
    public function createCategory($title,$picture){      
        $sentencia = $this->DB->prepare("CALL SP_INS_CATEGORY(?,?,?,@last)");
	$sentencia->bindParam(1, $title,    PDO::PARAM_STR);
	$sentencia->bindParam(2, $picture,  PDO::PARAM_STR);
	$sentencia->bindValue(3, time(),    PDO::PARAM_INT);
	$sentencia->execute();
	$sentencia->closeCursor();
        $result = $this->DB->query("SELECT @last AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10); 

        if($code == 1) {
            // Accion realizada con exito
            return true;
        } else {
            if($code == 2) {
                // Titulo de categoria ya existe y no se pudo insertar
                return false;
            } else {
                // Error: No se pudo insertar
                return false;
            }
        }
    }
    
    public function findCategoryById($id) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_CATEGORY_BY_ID(?)");
	$sentencia->bindParam(1, $id, PDO::PARAM_INT);
	$sentencia->execute();
	$result = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();	
	if(!empty($result)) {
            return $result[0];
        } else {
            return array();
        }
    }
    
    public function updateCategory($id,$title,$picture) {
        $sentencia = $this->DB->prepare("CALL SP_UPD_CATEGORY(?,?,?,?,@result)");
	$sentencia->bindParam(1, $id,      PDO::PARAM_INT);
	$sentencia->bindParam(2, $title,   PDO::PARAM_STR);
	$sentencia->bindParam(3, $picture, PDO::PARAM_STR);
	$sentencia->bindValue(4, time(),   PDO::PARAM_INT);
	$sentencia->execute();
	$sentencia->closeCursor();
        $result = $this->DB->query("SELECT @result AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10); 
        if($code == 1) {
            // Accion realizada con exito
            return true;
        } else {
            if($code == 2) {
                // Titulo de categoria ya existe y no se pudo actualizar. O 
                // id no existe para algun registro
                return false;
            } else {
                // Error: No se pudo insertar
                return false;
            }
        }
    }

    public function deleteCategory($id) {
        $sentencia = $this->DB->prepare("CALL SP_DEL_CATEGORY(?,@result)");
	$sentencia->bindParam(1, $id, PDO::PARAM_INT);
	$sentencia->execute();
	$sentencia->closeCursor();
	$result = $this->DB->query("SELECT @result AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10); 
        if($code == 1) {
            // Accion realizada con exito
            return true;
        } else {
            if($code == 2) {
                // Id no existe para algun registro de igual manera se regresa exito
                return true;
            } else {
                // Error: No se pudo insertar
                return false;
            }
        }
    }
    
    public function findCategoryByName($name) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_CATEGORY_BY_NAME(?)");
	$sentencia->bindParam(1, $name, PDO::PARAM_STR);
	$sentencia->execute();
	$result = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$sentencia->closeCursor();	
	if(!empty($result)) {
            return $result[0];
        } else {
            return array();
        }
    }
    
    /**********************************************************************************************/
    /**********************************************************************************************/
    /**********************************FIND BUSINESS BY METHODS************************************/
    /**********************************************************************************************/
    /**********************************************************************************************/
    public function findBusinessCountWithCriteria($criteria='') {
        $sentencia = $this->DB->prepare("CALL SP_SEL_BUS_COUNT_WITH_CRITERIA(?,@count)");
        $sentencia->bindParam(1, $criteria, PDO::PARAM_STR);
	$sentencia->execute();
	$sentencia->closeCursor();
	$result = $this->DB->query("SELECT @count AS count")->fetch(PDO::FETCH_ASSOC);
        $total = intval($result['count'], 10);
	return $total;
    }
    
    public function findAllBusinessWithPagingWithCriteria($offset=0,$count=0,$criteria='') {
        $result = $this->DB->prepare("CALL SP_SEL_BUS_WITH_PAGING_CRITERIA(?,?,?)");
	$result->bindParam(1, $count,    PDO::PARAM_INT);
	$result->bindParam(2, $offset,   PDO::PARAM_INT);
        $result->bindParam(3, $criteria, PDO::PARAM_STR);
	$result->execute();
	$business = $result->fetchAll(PDO::FETCH_ASSOC);
	$result->closeCursor();
	return $business;
    }
    
    /**
     * Encuentra un negocio por su token
     *
     * @param  string $token
     * @return array
     */
    public function findBusinessByToken($token) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_BUS_BY_TOKEN(?)");
        $sentencia->bindParam(1, $token, PDO::PARAM_STR);
        $sentencia->execute();
        $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        if(!empty($result)) {
            return $result[0];
        } else {
            return null;
        }
    }

    /**
     * Encuentra el negocio al cual se tiene que enviar la notificacion push. Si
     * ya es contacto se hace hacia ese de lo contrario encuentra cual de todos
     * los dispositivos registrados por el negocio le toca ser agregado
     * 
     * @param string $id
     * @return business Array with commerce data
     */
    public function findBusinessToPush($id,$fromId) {
        $sentencias = $this->DB->prepare("CALL SP_FIND_BUS_TO_PUSH(?,?)");
        $sentencias->bindParam(1, $id,     PDO::PARAM_INT);
        $sentencias->bindParam(2, $fromId, PDO::PARAM_INT);
        $sentencias->execute();
        $result  = $sentencias->fetchAll(PDO::FETCH_ASSOC);
        $sentencias->closeCursor();
        if(!empty($result)) {
            $commerce = $result[0];
        } else {
            $commerce = null;
        }
        
        if($commerce != null) {
            if( isset($commerce['os_type']) && isset($commerce['push_token']) ) {
                if($commerce['os_type'] == 1) { //iOS
                    $commerce['ios_push_token'] = $commerce['push_token'];
                } else {
                    if($commerce['os_type'] == 2) { //Android
                        $commerce['android_push_token'] = $commerce['push_token'];
                    } else {
                        $arr = array('message' => 'Push token no valido', 'error' => 'No se pudo enviar notificacion push');
                        return json_encode($arr);
                    }
                }
                unset($commerce['os_type']);
                unset($commerce['push_token']);
            } else {
                return null;
            }
        }
        
        return $commerce;
    }
    
    /************************************************************************************************************************/
    /************************************************************************************************************************/
    /************************************************************************************************************************//************************************************************************************************************************/
    /************************************************************************************************************************/
    /************************************************************************************************************************/
    /************************************************************************************************************************//************************************************************************************************************************/
    
    
    
    public function findBusinessByEmailOrName($value,$action) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_BUS_BY_EMAIL_NAME(?,?,@valor)");
        $sentencia->bindParam(1, $action, PDO::PARAM_INT);
        $sentencia->bindParam(2, $value,  PDO::PARAM_STR);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result   = $this->DB->query("SELECT @valor AS _id")->fetch(PDO::FETCH_ASSOC);
        $business = intval($result['_id'], 10);
        return $business;
    }
    
    /**
     * Finds a commerce by id.
     * 
     * @param string $id
     * @param boolean $deletePersonalInfo If true deletes email. Default <b>true</b>
     * @param boolean $getContacts If true get contacts. Default <b>false</b>
     * @param boolean $deletePassword If true deletes password. Default <b>true</b>
     * @param string $token (Only when getting contacts) Needed to get contacts
     * @return array with commerce data
     */
    public function findBusinessById($id,$deletePersonalInfo = true,$deletePassword = true) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_BUS_BY_ID(?)");
        $sentencia->bindParam(1, $id, PDO::PARAM_INT);
        $sentencia->execute();
        $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        if(!empty($result)) {
            $userFound = $this->reformatBusinessData($result[0],$deletePersonalInfo,$deletePassword);
        } else {
            $userFound = null;
        }
        return $userFound;
    }
    
    /**
     * Finds a commerce by id when is added as a contact
     * 
     * @param string $id
     * @param boolean $deletePersonalInfo If true deletes email. Default <b>true</b>
     * @param boolean $getContacts If true get contacts. Default <b>false</b>
     * @param boolean $deletePassword If true deletes password. Default <b>true</b>
     * @param string $token (Only when getting contacts) Needed to get contacts
     * @return array with commerce data
     */
    public function findBusinessByIdApp($id) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_BUS_BY_ID_APP(?)");
        $sentencia->bindParam(1, $id, PDO::PARAM_INT);
        $sentencia->execute();
        $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        if(!empty($result)) {
            return $result[0];
        } else {
            return null;
        }
    }
    
    /**********************************************************************************************/
    /**********************************************************************************************/
    /*************************************FIND USER BY METHODS*************************************/
    /**********************************************************************************************/
    /**********************************************************************************************/
    /**
     * Finds admin user by id
     *
     * @param  string $id
     * @return array with admin data.
     */
    public function findAdminById($id) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_ADMIN_BY_ID(?)");
        $sentencia->bindParam(1, $id, PDO::PARAM_INT);
        $sentencia->execute();
        $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        if(!empty($result)) {
            return $result[0];
        } else {
            return null;
        }
    }
    
    /**
     * Encuentra un usuario por <b>id<b/>
     * 
     * @param string $id <b>id<b/> que se busca
     * @param boolean $deletePersonalInfo 
     *          Elimina <b>email</b> y <b>token</b> de los datos obtenidos. <br>
     *          Valor por defecto es <b>true</b>
     * @param boolean $deletePassword
     *          Elimina <b>password</b> de los datos obtenidos. <br>
     *          Valor por defecto es <b>true</b>
     * @param integer $os
     *          Tipo de  <b>sistema operativo</b>. Valor por defecto es <b>0</b>
     * @return array Datos del usuario asociado al id.
     */
    public function findUserById($id,$deletePersonalInfo = true,$deletePassword = true,$os = 0) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_USER_BY_ID(?,?)");
        $sentencia->bindParam(1, $os, PDO::PARAM_INT);
        $sentencia->bindParam(2, $id, PDO::PARAM_INT);
        $sentencia->execute();
        $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        if(!empty($result)) {
            $user = $this->reformatUserData($result[0],$deletePersonalInfo,$deletePassword);
        } else {
            $user = null;
        }
        return $user;
    }
    
    /**
     * Finds a user by name or email
     *
     * @param  string $email
     * @return array
     */
    public function findUserByEmailOrName($value,$action) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_USER_BY_EMAIL_NAME(?,?,@valor)");
        $sentencia->bindParam(1, $action, PDO::PARAM_INT);
        $sentencia->bindParam(2, $value,  PDO::PARAM_STR);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @valor AS _id")->fetch(PDO::FETCH_ASSOC);
        $user   = intval($result['_id'], 10);
        return $user;
    }
    
    /**
     * Encuentra un usuario por su token.
     *
     * @param  string $token
     * @return array
     */
    public function findUserByToken($token) {
        //Get which business needs to be added as contact
        $sentencia = $this->DB->prepare("CALL SP_SEL_USER_BY_TOKEN(?)");
        $sentencia->bindParam(1, $token, PDO::PARAM_STR);
        $sentencia->execute();
        $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        if(!empty($result)) {
            $user = $result[0];
        } else {
            $user = null;
        }
        return $user;
    }
    
    public function findUserCount() {
        $sentencia = $this->DB->prepare("CALL SP_SEL_USER_COUNT(@count)");
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @count AS total")->fetch(PDO::FETCH_ASSOC);
        $total = intval($result['total'], 10);
        return $total;
    }
    /**********************************************************************************************/
    /**********************************************************************************************/
    /****************************************USER METHODS******************************************/
    /**********************************************************************************************/
    /**********************************************************************************************/
    public function deleteUser($userId){
        $sentencia = $this->DB->prepare("CALL SP_DEL_USER(?,@result)");
	$sentencia->bindParam(1, $userId, PDO::PARAM_INT);
	$sentencia->execute();
	$sentencia->closeCursor();
        $result = $this->DB->query("SELECT @result AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10); 
        if($code == 1) {
            // Accion realizada con exito
            return true;
        } else {
            if($code == 2) {
                // Id no existe para algun registro de igual manera se regresa exito
                return true;
            } else {
                // Error: No se pudo insertar
                return false;
            }
        }
    }
    
    /**
     * Actualiza la información de un usuario. <br></br>
     *  
     * De uso exclusivo para las aplicaciones moviles.
     * 
     * @param int $userId
     * @param int $action
     * @param string $value
     * @return array con los datos del usuario, mensaje de error
     * si no se puedo actualizar
     */
    public function updateUserAppData($userId,$action,$value){
        //Validate value before updating
        switch ($action) {
            case 3: //Email
                if (!\Conversa\Utils::checkEmailIsValid($value) && !$this->checkEmailIsUnique($value)) {
                    return array('message' => 'update user error!', 'error' => 'logout');
                }                
                break;
            case 4: //Name
                if ( !$this->checkUserNameIsUnique($value) ) {
                    return array('message' => 'update user error!', 'error' => 'logout');
                }
                break;
            case 6: //Birthday
                $date  = date("Y-m-d", $value);
                $value = $date;
                break;
            case 7: //Gender
                if ( strlen($value) != 1 ) {
                    return array('message' => 'update user error!', 'error' => 'logout');
                }
                break;
        }
        
        $sentencia = $this->DB->prepare("CALL SP_UPD_USER_APP_INFO(?,?,?,?,@valor)");
        $sentencia->bindParam(1, $action, PDO::PARAM_INT);
        $sentencia->bindParam(2, $userId, PDO::PARAM_INT);
        $sentencia->bindValue(3, time(),  PDO::PARAM_INT);
        $sentencia->bindParam(4, $value,  PDO::PARAM_STR);
        $sentencia->execute();
        $sentencia->closeCursor();
        $query = $this->DB->query("SELECT @valor AS resultado")->fetch(PDO::FETCH_ASSOC);
        $result = intval($query['resultado'], 10);

        if($result == 1) {
            return array('success' => true);
        } else {
            return array('error' => true);
        }
    }
    
    /**
      * Actualiza la información de un usuario
      * 
      * @param user $userId
      * @param string $user
      * @param boolean $secure
      * @return array con los datos del usuario, mensaje de error
      * si no se puedo actualizar
      */
    public function updateUser($userId,$user,$secure = true) {
        $originalData = $this->findUserById($userId,false,false,0);

        if (!isset($user['name'])) {
            $user['name'] = $originalData['name'];
        }

        if(!$secure) {
            if (!isset($user['email'])) {
                $user['email']    = $originalData['email'];
            }
            if (!isset($user['password'])) {
                $user['password'] = $originalData['password'];
            }
        } else {
            $user['email']    = '';
            $user['password'] = '';
        }

        if (!isset($user['about'])) {
            $user['about'] = $originalData['about'];
        }

        if (!isset($user['online_status'])) {
            $user['online_status'] = $originalData['online_status'];
        }

        if (!isset($user['birthday'])) {
            $user['birthday'] = $originalData['birthday'];
        }

        if (!isset($user['gender'])) {
            $user['gender'] = $originalData['gender'];
        }

        if (!isset($user['avatar_file_id'])) {
            $user['avatar_file_id'] = $originalData['avatar_file_id'];
        }

        if (!isset($user['avatar_thumb_file_id'])) {
            $user['avatar_thumb_file_id'] = $originalData['avatar_thumb_file_id'];
        }

        $sentencia = $this->DB->prepare("CALL SP_UPD_USER_INFO(?,?,?,?,?,?,?,?,?,?,?,?,@result)");
        $sentencia->bindParam(1,  $user['name'],           PDO::PARAM_STR);
        $sentencia->bindParam(2,  $user['about'],          PDO::PARAM_STR);
        $sentencia->bindParam(3,  $user['birthday'],       PDO::PARAM_STR);
        $sentencia->bindParam(4,  $user['gender'],         PDO::PARAM_INT);
        $sentencia->bindParam(5,  $user['avatar_file_id'], PDO::PARAM_STR);
        $sentencia->bindParam(6,  $user['avatar_thumb_file_id'], PDO::PARAM_STR);
        $sentencia->bindValue(7,  time(),            PDO::PARAM_INT);
        $sentencia->bindParam(8,  $user['email'],    PDO::PARAM_STR);
        $sentencia->bindParam(9,  $user['password'], PDO::PARAM_STR);
        $sentencia->bindParam(10, $userId,           PDO::PARAM_INT);
        $sentencia->bindParam(11, $secure,           PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
        $query = $this->DB->query("SELECT @result AS resultado")->fetch(PDO::FETCH_ASSOC);
        $result = intval($query['resultado'], 10);

        if($result == 1) {
            return $this->findUserById($userId,false,false,0);
        } else {
            return $originalData;
        }
    }
    
    /**
     * 
     * @param type $userName
     * @param type $email
     * @param type $password
     * @param type $birthday
     * @param type $gender
     * @param type $about
     * @param type $onlineStatus
     * @param type $avatarFile
     * @param type $thumbFile
     * @return type
     */
    public function createUser($userName,$email,$password,$birthday,$gender,$about,$onlineStatus,$avatarFile,$thumbFile) {
        $sentencia = $this->DB->prepare("CALL SP_INS_USER(?,?,?,?,?,?,?,?,?,?,@result)");
	$sentencia->bindParam(1,  $userName,     PDO::PARAM_STR);
	$sentencia->bindParam(2,  $email,        PDO::PARAM_STR);
	$sentencia->bindParam(3,  $password,     PDO::PARAM_STR);
	$sentencia->bindParam(4,  $birthday,     PDO::PARAM_STR);
        $sentencia->bindParam(5,  $gender,       PDO::PARAM_INT);
        $sentencia->bindParam(6,  $about,        PDO::PARAM_STR);
        $sentencia->bindParam(7,  $avatarFile,   PDO::PARAM_STR);
        $sentencia->bindParam(8,  $thumbFile,    PDO::PARAM_STR);
        $sentencia->bindValue(9,  time(),        PDO::PARAM_INT);
        $sentencia->bindValue(10, 0,             PDO::PARAM_INT);
	$sentencia->execute();
	$sentencia->closeCursor();
        $result = $this->DB->query("SELECT @result AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10);
        return $code;
    }
    
    /**********************************************************************************************/
    /**********************************************************************************************/
    /**************************************BUSINESS METHODS****************************************/
    /**********************************************************************************************/
    /**********************************************************************************************/
    /**
     * Actualiza la información de un usuario <br></br>
     * 
     * @param type $userId
     * @param type $action
     * @param type $token
     * @return type
     */
    public function updateBusinessAppData($userId,$action,$value,$token) {
        $originalData = $this->findBusinessById($userId,false,false);
        
        if(is_null($originalData)) {
            return array('error' => true);
        }
        
        switch ($action) {
            case 3: //Email
                if (!\Conversa\Utils::checkEmailIsValid($value) && !$this->checkEmailIsUnique($value)) {
                    return array('message' => 'update user error!', 'error' => 'logout');
                }                
                break;
            case 4: //Name
                if ( !$this->checkUserNameIsUnique($value) ) {
                    return array('message' => 'update user error!', 'error' => 'logout');
                }
                break;
        }
        
        $sentencia = $this->DB->prepare("CALL SP_UPD_BUS_APP_INFO(?,?,?,?,?,@valor)");
        $sentencia->bindParam(1, $action, PDO::PARAM_INT);
        $sentencia->bindParam(2, $userId, PDO::PARAM_INT);
        $sentencia->bindParam(3, $token,  PDO::PARAM_STR);
        $sentencia->bindValue(4, time(),  PDO::PARAM_INT);
        $sentencia->bindParam(5, $value,  PDO::PARAM_STR);
        $sentencia->execute();
        $sentencia->closeCursor();
        $query = $this->DB->query("SELECT @valor AS resultado")->fetch(PDO::FETCH_ASSOC);
        $result = intval($query['resultado'], 10);

        if($result == 1) {
            return array('success' => true);
        } else {
            return array('error' => true);
        }
    }
    
    public function addRemoveLocation($id,$pushId,$action) {
        $sentencia = $this->DB->prepare("CALL SP_INSUPD_LOCATION(?,?,?,@last)");
	$sentencia->bindParam(1, $id,     PDO::PARAM_INT);
	$sentencia->bindParam(2, $pushId, PDO::PARAM_INT);
	$sentencia->bindValue(3, time(),  PDO::PARAM_INT);
        $sentencia->bindValue(4, $action, PDO::PARAM_INT);
	$sentencia->execute();
	$sentencia->closeCursor();
        $result = $this->DB->query("SELECT @last AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10);

        if($code == 1) {
            // Accion realizada con exito
            return true;
        } else {
            if($code == 2) {
                // Titulo de categoria ya existe y no se pudo insertar
                return false;
            } else {
                // Error: No se pudo insertar
                return false;
            }
        }
    }
    
    /**
     * Finds business statistics
     * 
     * @param string $id
     * @param string $pushId
     * @return business Array with commerce statistics data
     */
    public function getBusinessStatistics($id,$pushId) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_BUS_STATISTICS(?,?)");
        $sentencia->bindParam(1, $id,     PDO::PARAM_INT);
        $sentencia->bindParam(2, $pushId, PDO::PARAM_INT);
        $sentencia->execute();
        $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        if(!empty($result)) {
            $statistics = $result[0];
            $statistics['last_get'] = time();
            return $statistics;
        } else {
            return array();
        }
    }
    
    public function createBusiness($name,$email,$password,$about,$founded,$expired,$avatarFile,
                                   $thumbFile,$max_devices,$country,$id_category,$plan) {
        $conversaId = \Conversa\Utils::generateConversaIdForBusiness($name);
        $sentencia = $this->DB->prepare("CALL SP_INS_BUSINESS(?,?,?,?,?,?,?,?,?,?,?,?,?,?,@result)");
        $sentencia->bindValue(1,  time(),       PDO::PARAM_INT);
        $sentencia->bindParam(2,  $max_devices, PDO::PARAM_INT);
        $sentencia->bindParam(3,  $country,     PDO::PARAM_INT);
        $sentencia->bindParam(4,  $id_category, PDO::PARAM_INT);
        $sentencia->bindParam(5,  $plan,        PDO::PARAM_INT);
        $sentencia->bindParam(6,  $founded,     PDO::PARAM_STR);
        $sentencia->bindParam(7,  $expired,     PDO::PARAM_STR);
        $sentencia->bindParam(8,  $name,        PDO::PARAM_STR);
        $sentencia->bindParam(9,  $conversaId,  PDO::PARAM_STR);
        $sentencia->bindParam(10, $email,       PDO::PARAM_STR);
        $sentencia->bindParam(11, $password,    PDO::PARAM_STR);
        $sentencia->bindParam(12, $about,       PDO::PARAM_STR);
        $sentencia->bindParam(13, $avatarFile,  PDO::PARAM_STR);
        $sentencia->bindParam(14, $thumbFile,   PDO::PARAM_STR);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @result AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10);
        if($code == 1) {
            return true;
        } else {
            return false;
        }
    }
    
    /**
     * 
     * @param type $userId
     * @param type $user
     * @param type $secure
     * @param type $updateTokenTable
     * @return type
     */
    public function updateBusiness($userId,$user,$secure = true){
        $originalData = $this->findBusinessById($userId,$secure,$secure);
        
        $now = time();
        
        if (!isset($user['name'])) {
            $user['name'] = $originalData['name'];
        }

        if(!$secure){
            if (!isset($user['email'])) {
                $user['email'] = $originalData['email'];
            }
            if (!isset($user['password'])) {
                $user['password'] = $originalData['password'];
            }
            
            if (!isset($user['expiration'])) {
                $user['expiration'] = $originalData['expiration'];
            }

            if (!isset($user['max_devices'])) {
                $user['max_devices'] = $originalData['max_devices'];
            }

            if (!isset($user['plan'])) {
                $user['plan'] = $originalData['plan'];
            }
        }
                    
        if (!isset($user['about'])) {
            $user['about'] = $originalData['about'];
        }

        if (!isset($user['founded'])) {
            $user['founded'] = $originalData['founded'];
        }
        
        if (!isset($user['avatar_file_id'])) {
            $user['avatar_file_id'] = $originalData['avatar_file_id'];
        }

        if (!isset($user['avatar_thumb_file_id'])) {
            $user['avatar_thumb_file_id'] = $originalData['avatar_thumb_file_id'];
        }
        
        if (!isset($user['country'])) {
            $user['country'] = $originalData['country'];
        }
        
        if (!isset($user['id_category'])) {
            $user['id_category'] = $originalData['id_category'];
        }

        if($secure){
            $result = $this->DB->executeupdate(
                'UPDATE co_business SET 
                    bu_name = ?,
                    bu_about = ?,
                    bu_founded = ?,
                    bu_avatar_file_id = ?,
                    bu_avatar_thumb_file_id = ?,
                    bu_country = ?,
                    bu_id_category = ?,
                    bu_modified = ?
                    WHERE bu_id = ?', 
                array(
                    $user['name'],
                    $user['about'],
                    $user['founded'],
                    $user['avatar_file_id'],
                    $user['avatar_thumb_file_id'],
                    $user['country'],
                    $user['id_category'],
                    $now,
                    $userId));
        }else{
            $result = $this->DB->executeupdate(
                'UPDATE co_business SET 
                    bu_name = ?,
                    bu_email = ?,
                    bu_password = ?,
                    bu_about = ?,
                    bu_founded = ?,
                    bu_plan_expiration = ?,
                    bu_avatar_file_id = ?,
                    bu_avatar_thumb_file_id = ?,
                    bu_max_devices = ?,
                    bu_country = ?,
                    bu_id_category = ?,
                    bu_paid_plan = ?,
                    bu_modified = ?
                    WHERE bu_id = ?', 
                array(
                    $user['name'],
                    $user['email'],
                    $user['password'],
                    $user['about'],
                    $user['founded'],
                    $user['expiration'],
                    $user['avatar_file_id'],
                    $user['avatar_thumb_file_id'],
                    $user['max_devices'],
                    $user['country'],
                    $user['id_category'],
                    $user['plan'],
                    $now,
                    $userId));
        }

        if ($result) {
            return $this->findBusinessById($userId, false);
        } else {
            return null;
        }
    }
    
    public function deleteBusiness($businessId) {
        $sentencia = $this->DB->prepare("CALL SP_DEL_BUSINESS(?,@result)");
        $sentencia->bindParam(1,$businessId,PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @result AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10); 
        if($code == 1) {
            // Accion realizada con exito
            return true;
        } else {
            if($code == 2) {
                // Id no existe para algun registro de igual manera se regresa exito
                return false;
            } else {
                // Error: No se pudo insertar
                return false;
            }
        }
    }
    /**********************************************************************************************/
    /**********************************************************************************************/
    /****************************************MESSAGE METHODS******************************************/
    /**********************************************************************************************/
    /**********************************************************************************************/
    /**
     * 
     * @param type $messageId
     * @return type
     */
    public function deleteMessage($messageId) {
        $sentencia = $this->DB->prepare("CALL SP_DEL_MESSAGE(?,@result)");
        $sentencia->bindParam(1,$messageId,PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @result AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10); 
        if($code == 1) {
            // Accion realizada con exito
            return true;
        } else {
            if($code == 2) {
                // Id no existe para algun registro de igual manera se regresa exito
                return true;
            } else {
                // Error: No se pudo insertar
                return false;
            }
        }
    }
    
    /**
     * 
     * @param type $from
     * @param type $to
     * @param type $fromType
     * @param type $toType
     * @return type
     */
    public function updateReadAtAll($from,$to,$fromType,$toType) {
        $sentencia = $this->DB->prepare("CALL SP_UPD_MESSAGE_READ_AT(?,?,?,?,?,?,@total)");
        $sentencia->bindValue(1, 0,         PDO::PARAM_STR);
        $sentencia->bindParam(2, $from,     PDO::PARAM_INT);
        $sentencia->bindParam(3, $to,       PDO::PARAM_INT);
        $sentencia->bindParam(4, $fromType, PDO::PARAM_INT);
        $sentencia->bindParam(5, $toType,   PDO::PARAM_INT);
        $sentencia->bindValue(6, time(),    PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @total AS resultado")->fetch(PDO::FETCH_ASSOC);
        $code = intval($result['resultado'], 10);
        return $code;
    }
    
    /**
     * Agrega a la cuenta de mensaje reportado
     * 
     * @param int $messageId Id del mensaje
     */
    public function reportMessage($messageId) {
        $sentencia = $this->DB->prepare("CALL SP_UPD_MESSAGE_REPORT(?)");
        $sentencia->bindParam(1,$messageId,PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
    }
    
    /**
     * 
     * @param type $toUserType
     * @param type $fromUserType
     * @param type $fromUserId
     * @param type $toUserId
     * @param type $message
     * @param type $messageType
     * @param type $picture
     * @param type $picture_thumb
     * @param type $longitude
     * @param type $latitude
     */
    public function addNewMessage($toUserType,$fromUserType,$fromUserId,$toUserId,$message,$messageType,$picture,$picture_thumb,$longitude,$latitude) {
	$sentencia = $this->DB->prepare("CALL SP_INS_MESSAGE(?,?,?,?,?,?,?,?,?,?,?,?,@last)");
	$sentencia->bindParam(1,  $fromUserId,    PDO::PARAM_INT);
	$sentencia->bindParam(2,  $toUserId,      PDO::PARAM_INT);
	$sentencia->bindParam(3,  $fromUserType,  PDO::PARAM_INT);
	$sentencia->bindParam(4,  $toUserType,    PDO::PARAM_INT);
	$sentencia->bindParam(5,  $message,       PDO::PARAM_STR);
	$sentencia->bindValue(6,  time(),         PDO::PARAM_INT);
	$sentencia->bindParam(7,  $messageType,   PDO::PARAM_INT);
	$sentencia->bindValue(8,  1,              PDO::PARAM_INT);//User or Group
        $sentencia->bindParam(9,  $picture,       PDO::PARAM_STR);
        $sentencia->bindParam(10, $picture_thumb, PDO::PARAM_STR);
        $sentencia->bindParam(11, $longitude,     PDO::PARAM_INT);
        $sentencia->bindParam(12, $latitude,      PDO::PARAM_INT);
	$sentencia->execute();
	$sentencia->closeCursor();
        $result = $this->DB->query("SELECT @last AS resultado")->fetch(PDO::FETCH_ASSOC);
        $success = intval($result['resultado'], 10);
        
        if($success != 0) {
            $couchDBCompatibleResponse = array(
                'ok'  => true,
                'id'  => $success,
                'rev' => 'tmprev'
            );

            return $couchDBCompatibleResponse;
        } else {
            return null;
        }
    }
    
    /**
     * 
     * @param string $ownerType
     * @param string $targetType
     * @param string $ownerUserId
     * @param string $targetUserId
     * @param int $count
     * @param int $offset
     * @return type
     */
    public function getUserMessages($ownerType,$ownerUserId,$targetUserId,$count,$offset) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_USER_MESSAGES(?,?,?,?,?,?)");
        $sentencia->bindParam(1, $ownerType,    PDO::PARAM_INT);
        $sentencia->bindValue(2, 1,             PDO::PARAM_INT);
        $sentencia->bindParam(3, $targetUserId, PDO::PARAM_INT);
        $sentencia->bindParam(4, $ownerUserId,  PDO::PARAM_INT);
        $sentencia->bindParam(5, $count,        PDO::PARAM_INT);
        $sentencia->bindParam(6, $offset,       PDO::PARAM_INT);
        $sentencia->execute();
        $messages  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();        
        
        return $this->formatResult($messages,$offset);
    }
    
    /**
     * 
     * @param type $messageId
     * @return type
     */
    public function findMessageById($messageId) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_MESSAGE_BY_ID(?)");
        $sentencia->bindParam(1, $messageId, PDO::PARAM_INT);
        $sentencia->execute();
        $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        if(!empty($result)) {
            $message = $result[0];
        } else {
            $message = null;
        }
        return $message;
    }
    
    /**
     * APP ONLY. Usado cuando se piden todos los mensajes nuevos para un usuario.
     * Tiene un limite de 200 mensajes nuevos.
     * 
     * @param type $from
     * @param type $to
     * @param type $fromType
     * @param type $toType
     * @param type $lastId
     * @return type
     */
    public function getAllMessagesFrom($from,$to,$fromType,$lastId) {
        $fromType = intval($fromType);
        $to       = intval($to);
        $from     = intval($from);
        $lastId   = intval($lastId);
        $sentencia = $this->DB->prepare("CALL SP_SEL_MESSAGES_BY_ID(?,?,?,?,?)");
        $sentencia->bindParam(1, $fromType, PDO::PARAM_INT);
        $sentencia->bindValue(2, 1,         PDO::PARAM_INT);
        $sentencia->bindParam(3, $from,     PDO::PARAM_INT);
        $sentencia->bindParam(4, $to,       PDO::PARAM_INT);
        $sentencia->bindParam(5, $lastId,   PDO::PARAM_INT);
        $sentencia->execute();
        $messages  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        
        return $this->formatResult($messages,$lastId);
    }
    
    /**
     * 
     * @param type $userId
     * @param type $offset
     * @param type $count
     * @return type
     */
    public function getConversationHistory($userId,$offset=0,$count=10) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_CONV_HISTORY(?,?,?)");
        $sentencia->bindParam(1, $userId, PDO::PARAM_INT);
        $sentencia->bindParam(2, $count,  PDO::PARAM_INT);
        $sentencia->bindParam(3, $offset, PDO::PARAM_INT);
        $sentencia->execute();
        $messages  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();

        return $messages;
    }

    public function getConversationHistoryCount($userId) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_CONV_HIS_COUNT(?,@count)");
        $sentencia->bindParam(1, $userId, PDO::PARAM_INT);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @count AS total")->fetch(PDO::FETCH_ASSOC);
        $total = intval($result['total'], 10);
        return $total;
    }

    /**
     * Total de mensajes enviados en toda la plataforma
     * 
     * @return type
     */
    public function getMessageCount() {
        $sentencia = $this->DB->prepare("CALL SP_SEL_MESSAGE_COUNT(@count)");
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @count AS total")->fetch(PDO::FETCH_ASSOC);
        $total = intval($result['total'], 10);
        return $total;
    }
    
    /**********************************************************************************************/
    /**********************************************************************************************/
    /****************************************UTILS METHODS*****************************************/
    /**********************************************************************************************/
    /**********************************************************************************************/
    /**
     * Encuentra el usuario/negocio para el token recibido
     * 
     * @return array null si no se encuentra ningun usuario. _id, token [,push_id,location_id] del usuario
     */
    public function findValidToken($token,$type) {
        $sentencia = $this->DB->prepare("CALL SP_FIND_BY_TOKEN(?,?)");
        $sentencia->bindParam(1, $token, PDO::PARAM_STR);
        $sentencia->bindParam(2, $type,  PDO::PARAM_INT);
        $sentencia->execute();
        $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        if(!empty($result)) {
            return $result[0];
        } else {
            return null;
        }
    }
    
    /**
     * Obtiene el avatar de un usuario
     * 
     * @param type $id
     * @return type
     */
    public function getAvatarFileId($id) {
        $type = USER_TYPE;
        $sentencia = $this->DB->prepare("CALL SP_SEL_AVATAR(?,?)");
        $sentencia->bindParam(1, $id,   PDO::PARAM_INT);
        $sentencia->bindParam(2, $type, PDO::PARAM_INT);
        $sentencia->execute();
        $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        if(!empty($result)) {
            return $result[0];
        } else {
            return array();
        }
    }
    
    /**
     * Obtiene el avatar de un negocio
     * 
     * @param type $id
     * @return type
     */
    public function getAvatarFileIdForBusiness($id) {
        $type = BUSINESS_TYPE;
        $sentencia = $this->DB->prepare("CALL SP_SEL_AVATAR(?,?)");
        $sentencia->bindParam(1, $id,   PDO::PARAM_INT);
        $sentencia->bindParam(2, $type, PDO::PARAM_INT);
        $sentencia->execute();
        $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        if(!empty($result)) {
            return $result[0];
        } else {
            return array(); //return array('rows' => array(array('key' => "", 'value' => "")));
        }
    }

    /**
     * Agrega una peticion para cambio de password
     * 
     * @param type $toUserId
     * @return type
     */
    public function addPassworResetRequest($toUserId) {
        $token = \Conversa\Utils::randString(PASSRESET_TOKEN_LENGTH, PASSRESET_TOKEN_LENGTH);
        $data = array(
            'info'     => 'Peticion de cambio de password',
            'from'     => $toUserId,
            'fromType' => '1',
            'created'  => time(),
            'token'    => $token,
        );
        $this->logger->addDebug(print_r($data,true));
        
        $sentencia = $this->DB->prepare("CALL SP_INS_PASSWORD_RESET_REQUEST(?,?,?,@result)");
	$sentencia->bindParam(1,  $toUserId, PDO::PARAM_INT);
	$sentencia->bindParam(2,  $token,    PDO::PARAM_INT);
	$sentencia->bindValue(3,  time(),    PDO::PARAM_INT);
	$sentencia->execute();
	$sentencia->closeCursor();
        $result = $this->DB->query("SELECT @result AS resultado")->fetch(PDO::FETCH_ASSOC);
        $success = intval($result['resultado'], 10);
        
        if($success == 1 || $success == 2){
            return $token;
        } else {
            return null;
        }
    }
    
    /**
     * Obtiene la informacion de la peticion de cambio de contraseña
     * 
     * @param string $requestToken
     * @return array with password change information
     */
    public function getPassworResetRequest($requestToken) {
        $sentencia = $this->DB->prepare("CALL SP_SEL_PASSWORD_RESET_REQUEST(?)");
        $sentencia->bindParam(1, $requestToken, PDO::PARAM_STR);
        $sentencia->execute();
        $result  = $sentencia->fetchAll(PDO::FETCH_ASSOC);
        $sentencia->closeCursor();
        if(!empty($result)) {
            $resetRequest = $result[0];
            return $resetRequest;
        } else {
            return array();
        }
    }
    
    /**
     * Cambia el password e invalida todas las peticiones para el usuario que recibe
     * 
     * @param type $userId
     * @param type $newPassword
     */
    public function changePassword($userId,$newPassword) {
        $sentencia = $this->DB->prepare("CALL SP_UPD_PASSWORD(?,?,@result)");
        $sentencia->bindParam(1, $newPassword, PDO::PARAM_STR);
        $sentencia->bindParam(2, $userId,      PDO::PARAM_STR);
        $sentencia->execute();
        $sentencia->closeCursor();
        $result = $this->DB->query("SELECT @result AS resultado")->fetch(PDO::FETCH_ASSOC);
        $success = intval($result['resultado'], 10);
        if($success == 1 || $success == 2){
            return 1;
        } else {
            return 0;
        }
    }
    
    /**
     * Da formato a un mensaje para que sea compatible con la aplicacion movil
     * 
     * @param message $result
     * @param int $offset
     * @return type
     */
    public function formatResult($result,$offset = 0) {
        $newResultRows = array();
        
        foreach($result as $row){
            $newResultRows[] = array(
                'id'    => $row['_id'],
                'key'   => $row['_id'],
                'value' => $row
            );     
        }
        
        return array(
            'total_rows' => count($result),
            'offset' => $offset,
            'rows'  => $newResultRows
        );
    }
    
    /**
     * Remueve o guarda información del usuario: password, email, token.
     * 
     * @param array $user Información de usuario
     * @param boolean $deletePersonalInfo 
     *          Elimina <b>email</b> y <b>token</b> de los datos obtenidos. <br>
     *          Valor por defecto es <b>true</b>
     * @param boolean $deletePassword
     *          Elimina <b>password</b> de los datos obtenidos. <br>
     *          Valor por defecto es <b>true</b>
     * @return array Con la información del usuario limpia
     */
    public function reformatUserData($user,$deletePersonalInfo = true,$deletePassword = true) {
        if($deletePersonalInfo) {
            unset($user['email']);
            unset($user['token']);
        }
        
        if($deletePassword) {
            unset($user['password']);
        }
        
        return $user;
    }
    
    /**
     * Remueve o guarda información del negocio: password, email, token.
     * 
     * @param array $user Información de negocio
     * @param boolean $deletePersonalInfo 
     *          Elimina <b>email</b> y <b>token</b> de los datos obtenidos. <br>
     *          Valor por defecto es <b>true</b>
     * @param boolean $deletePassword
     *          Elimina <b>password</b> de los datos obtenidos. <br>
     *          Valor por defecto es <b>true</b>
     * @return array Con la información del usuario limpia
     */
    public function reformatBusinessData($user,$deletePersonalInfo = true,$deletePassword = true) {
        if($deletePersonalInfo) {
            unset($user['email']);
            unset($user['token']);
        }
        
        if($deletePassword) {
            unset($user['password']);
        }
        
        return $user;
    }
    
    /**
     * Verifies if email is already taken.
     * 
     * @param string $email
     * @return array con los datos del email, vacio si es unico
     */
    public function checkEmailIsUnique($email) {
        $user = $this->DB->fetchAssoc('SELECT us_id AS _id FROM co_user WHERE us_email = ?',array($email));
        
        if(isset($user['_id'])) {
            return false;
        } else {
            $commerce = $this->DB->fetchAssoc('SELECT bu_id AS _id FROM co_business WHERE bu_email = ?',array($email));
            
            if(isset($commerce['_id'])) {
                return false;
            } else {
                return true;
            }
        }
    }
    
    /**
     * Verifica si el nombre se encuentra disponible
     * 
     * @param string $name
     * @return array con los datos del name, vacio si es unico
     */
    public function checkUserNameIsUnique($name) {
        $user = $this->DB->fetchAssoc('SELECT us_id AS _id FROM co_user WHERE us_name = ?',array($name));
        
        if(isset($user['_id'])) {
            return false;
        } else {
            $commerce = $this->DB->fetchAssoc('SELECT bu_id AS _id FROM co_business WHERE bu_name = ?',array($name));
            
            if(isset($commerce['_id'])){
                return false;
            }else{
                return true;
            }
        }
    }
    
    /**********************************************************************************************/
    /**********************************************************************************************/
    /****************************************OTHER METHODS*****************************************/
    /**********************************************************************************************/
    /**********************************************************************************************/
    public function getAllPlans() {
        $query    = "select pt_id as _id, pt_name AS title from co_plan_type";
        $result   = $this->DB->fetchAll($query);
        return $result;
    }
    
    public function getAllCountries() {
        $query    = "select cnt_id as _id, cnt_name AS name from co_country";
        $result   = $this->DB->fetchAll($query);
        return $result;
    }
    
    public function getLastLoginedUsersCount() {
        $timeFrom = time() - 60 * 60 * 24;
        $query    = "select count(*) as count from co_message where me_created > {$timeFrom}";
        $result   = $this->DB->fetchColumn($query);
        return $result;
    }
    
    public function findAllUsersWithPagingWithCriteria($offset = 0,$count=0,$criteria='',$criteriaValues=array()) {
        $query = "select * from user where 1 = 1 {$criteria} order by _id ";
        
        if($count != 0){
            $query .= " limit {$count} offset {$offset} ";
        }
        
        $result = $this->DB->fetchAll($query,$criteriaValues);
        
        $formatedUsers = array();
        foreach($result as $user){
            $user = $this->reformatUserData($user,false);
            $formatedUsers[] = $user;
        }
        
        return $this->formatResult($formatedUsers);
    }

    public function findUserCountWithCriteria($criteria = '',$criteriaValues=array()) {
        $query  = "select count(*) as count from user where 1 = 1 {$criteria}";
        $result = $this->DB->fetchColumn($query,$criteriaValues);
        return $result;
    }

    public function getContactsByUserId($userId) {
        $query = "SELECT * FROM user WHERE _id IN ("
                . "SELECT contact_user_id FROM user_contact WHERE "
                . "user_id = ?)";
        $users = $this->DB->fetchAll($query,array($userId));
        return $users;
    }
    
    public function getContactedByUserId($userId) {
        $query = "SELECT * FROM user WHERE _id IN ("
                . "SELECT user_id FROM user_contact WHERE "
                . "contact_user_id = ?)";
        $users = $this->DB->fetchAll($query,array($userId));
        return $users;
    }
}