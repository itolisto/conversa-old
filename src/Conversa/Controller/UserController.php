<?php
/**
 * Created by IntelliJ IDEA.
 * User: dinko
 * Date: 10/22/13
 * Time: 2:45 PM
 * To change this template use File | Settings | File Templates.
 */

namespace Conversa\Controller;

use Silex\Application;
use Symfony\Component\HttpFoundation\Request;

class UserController extends ConversaBaseController {

    public function connect(Application $app) {
        $controllers = $app['controllers_factory'];
        $self = $this;

        $this->setupAuthMethod($self,$app,$controllers);
        $this->setupCreateUserMethod($self,$app,$controllers);
        $this->setupUpdateUserMethod($self,$app,$controllers);
        $this->setupFindUserMethod($self,$app,$controllers);
        $this->setupGetAvatarFileIdMethod($self,$app,$controllers);
        $this->setupFavoriteMethod($self,$app,$controllers);

        return $controllers;
    }
    
    /**
     * Función para validar el ingreso a la aplicación
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers
     */
    private function setupAuthMethod($self,$app,$controllers) {
        $controllers->post('/auth', function (Request $request) use ($app,$self) {
            
            $requestBody = $request->getContent();
            $requestBodyArray = json_decode($requestBody,true);

            $email      = trim($requestBodyArray['email']);
            $password   = trim($requestBodyArray['password']);
        
            if (empty($email) || empty($password)) {
                return $self->returnErrorResponse("Empty fields");
            }
            
            if( !\Conversa\Utils::checkEmailIsValid($email) ) {
                return $self->returnErrorResponse("Email is not valid");
            }

            $authResult = $app['conversadb']->doConversaAuth($email,$password);
            
            if(is_null($authResult)) {
                return $self->returnErrorResponse("Not valid");//return json_encode(1);
            } else {
                return json_encode($authResult);
            }
        })->before($app['beforeApiGeneral']);
    }

    /**
     * Función para crear nuevo usuario
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers
     */
    private function setupCreateUserMethod($self,$app,$controllers){
        $controllers->post('/createUser', function (Request $request) use ($app,$self) {
    
            $requestBody = $request->getContent();
            
            if(!$self->validateRequestParams($requestBody,array(
                'name', 'email', 'password', 'birthday', 'gender'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }
            
            $requestBodyAry = json_decode($requestBody,true);
            $username       = trim($requestBodyAry['name']);
            $email          = trim($requestBodyAry['email']);
            $password       = trim($requestBodyAry['password']);
            $birthday       = trim($requestBodyAry['birthday']);
            $gender         = trim($requestBodyAry['gender']);
            
            if (empty($username) || empty($email) || empty($password) ||
                empty($birthday) || empty($gender)) {
                return $self->returnErrorResponse("Empty fields");
            }
            
            if( !\Conversa\Utils::checkEmailIsValid($email) ){
                return $self->returnErrorResponse("Email is not valid");
            }
            
            $isValid = \Conversa\Utils::validateDate($birthday, 'Y-m-d');
            if (!$isValid) {
                return $self->returnErrorResponse("Not valid date");
            }
            
            $today = date("Y-m-d");
            $yearOfBirthday = \DateTime::createFromFormat("Y-m-d", $birthday)->format("Y");
            $yearToday      = \DateTime::createFromFormat("Y-m-d", $today)->format("Y");
            
            if(is_numeric($yearOfBirthday) && is_numeric($yearToday)) {
                if ($yearToday - $yearOfBirthday < 18) {
                    return $self->returnErrorResponse("You must be at least 18 years old");
                } 
            } else {
                return $self->returnErrorResponse("Birthday is not valid");
            }
            
            if(is_numeric($gender)) {
                if($gender < 1 || $gender > 2) {
                    return $self->returnErrorResponse("Gender is not valid");
                } 
            } else {
                return $self->returnErrorResponse("Gender is not valid");
            }

            $created = $app['conversadb']->createUser(
              $username, $email, $password, $birthday, $gender);
            
            if($created == 1 ) {
                return json_encode(array('ok' => true));
            } else {
               if($created == 2 ) {
                   return $self->returnErrorResponse("Email is already taken");
               } else {
                   if($created == 3 ) {
                       return $self->returnErrorResponse("Name is already taken");
                   } else {
                       // Error en la insercion
                       return $self->returnErrorResponse("Error while creating user");
                   }
               }
            }
        })->before($app['beforeApiGeneral']);
    }

    /**
     * Función para actualizar la información de usuario
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers
     */
    private function setupUpdateUserMethod($self,$app,$controllers){
        $controllers->post('/updateUser', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $userData = $request->getContent();

            if(!$self->validateRequestParams($userData,array(
                'action', 'value'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($userData,true);
            $action = intval($requestBodyAry['action']);
            $value  = trim($requestBodyAry['value']);

            if($action < 1 || $action > 7) {
                return $self->returnErrorResponse("Actualización no encontrada.");
            }

            if(empty($value)) {
                return $self->returnErrorResponse("Nuevo valor no puede estar vacio");
            }
            
            if($action == 6) {
                $isValid = $this->validateDate($value, 'Y-m-d');
                if (!$isValid) {
                    return $self->returnErrorResponse("Not valid date");
                }
            }

            $result = $app['conversadb']->updateUserAppData($currentUser['_id'],$action,$value);

            return json_encode($result);
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
    }

    /**
     * Función para encontrar un usuario por <p>
     *      1. id <br>
     *      2. email <br>
     *      3. name [nombre] <br>
     * con el respectivo valor que recibe como segundo
     * parámetro en la ruta.
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers   xxx/api/findUser/{type}/{value}/{user_type}
     */
    private function setupFindUserMethod($self,$app,$controllers){
        $controllers->get('/findUser/{type}/{value}', function ($type,$value) use ($app,$self) {

            if(empty($type) || empty($value)){
                return $self->returnErrorResponse("Faltan parámetros para realizar búsqueda.");
            }

            $value = urldecode($value);

            switch ($type){
                case "id":
                    $userIds = explode(",",$value);
                    if(count($userIds) == 1) {
                        $result = $app['conversadb']->findBusinessById($value);
                    }
                    break;
                case "contacts":
                    $result = $app['conversadb']->findContactsById($value);
                    break;
                default:
                    return $self->returnErrorResponse("Búsqueda no encontrada.");
            }

            if($result == null) {
                return "{}";                   
            }

            return json_encode($result);
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
    }

    /**
     * Función para encontrar el archivo de imagen del usuario
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers
     */
    private function setupGetAvatarFileIdMethod($self,$app,$controllers){
        $controllers->get('/GetAvatarFileId/{user_id}', function ($user_id) use ($app,$self) {

            if(empty($user_id)){
                return $self->returnErrorResponse("insufficient params");
            }

            $result = $app['conversadb']->getAvatarFileId($user_id);
            return json_encode($result);
        })->before($app['beforeApiGeneral']);
    }
    
    /**
     * Funciones para agregar y remover favoritos
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers
     */
    private function setupFavoriteMethod($self,$app,$controllers){
        $controllers->post('/setFavorite', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $requestBody = $request->getContent();

            if(!$self->validateRequestParams($requestBody,array(
                'business_id'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($requestBody,true);
            $businessId     = trim($requestBodyAry['business_id']);

            $result = $app['conversadb']->addRemoveFavorite($currentUser['_id'],$businessId,1);

            if($result == 1){
                return json_encode(array('success' => true));
            } else {
                return $self->returnErrorResponse("No se ha podido agregar favorito!");
            }
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        /* ********************************************************************** */
        $controllers->post('/unsetFavorite', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $requestBody = $request->getContent();

            if(!$self->validateRequestParams($requestBody,array(
                'business_id'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($requestBody,true);
            $businessId     = trim($requestBodyAry['business_id']);

            $result = $app['conversadb']->addRemoveFavorite($currentUser['_id'],$businessId,0);

            if($result == 1) {
                return json_encode(array('success' => true));
            } else {
                return $self->returnErrorResponse("No se ha podido eliminar favorito!");
            }
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
    }
}