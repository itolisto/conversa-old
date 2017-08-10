<?php
namespace Conversa\Controller;

use Silex\Application;
use Symfony\Component\HttpFoundation\Request;

class BusinessController extends ConversaBaseController {

    public function connect(Application $app) {
        $controllers = $app['controllers_factory'];
        $self = $this;

        $this->setupAuthMethod($self,$app,$controllers);
        $this->setupCreateUserMethod($self,$app,$controllers);
        $this->setupUpdateUserMethod($self,$app,$controllers);
        $this->setupFindUserMethod($self,$app,$controllers);
        $this->setupGetAvatarFileIdMethod($self,$app,$controllers);
        $this->setupStatisticsMethod($self,$app,$controllers);
        $this->setupAutomateMethod($self,$app,$controllers);
        $this->setupLocationMethod($self,$app,$controllers);

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
        $controllers->post('/authBusiness', function (Request $request) use ($app,$self) {
            
            $requestBody = $request->getContent();
            
            if(!$self->validateRequestParams($requestBody,array('email', 'password'))) {
                return $self->returnErrorResponse("insufficient params");
            }
            
            $requestBodyArray = json_decode($requestBody,true);
            $email    = trim($requestBodyArray['email']);
            $password = trim($requestBodyArray['password']);
        
            if (empty($email) || empty($password)) {
                return $self->returnErrorResponse("Empty fields");
            }
            
            if( !\Conversa\Utils::checkEmailIsValid($email) ) {
                return $self->returnErrorResponse("Email is not valid");
            }
            
            if( !\Conversa\Utils::checkPasswordIsValid($password) ) {
                return $self->returnErrorResponse("Password is not valid");
            }

            $currentUser = $app['currentUser'];
            $authResult  = $app['conversadb']->doConversaBusinessAuth($email,$password,$currentUser['os']);
                    
            if(is_null($authResult)) {
                return $self->returnErrorResponse("An error ocurred or business not found");
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
        $controllers->post('/createBusiness', function (Request $request) use ($app,$self) {
    
            $requestBody = $request->getContent();
            
            if(!$self->validateRequestParams($requestBody,array(
                'name', 'email', 'password', 'about', 'founded',
                'avatar', 'country', 'city', 'address', 'id_category'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }
            
            $requestBodyAry = json_decode($requestBody,true);
            $username       = trim($requestBodyAry['name']);
            $email          = trim($requestBodyAry['email']);
            $password       = trim($requestBodyAry['password']);
            $about          = trim($requestBodyAry['about']);
            $founded        = trim($requestBodyAry['founded']);
            $avatar         = trim($requestBodyAry['avatar']);
            $country        = trim($requestBodyAry['country']);
            $city           = trim($requestBodyAry['city']);
            $address        = trim($requestBodyAry['address']);
            $id_category    = trim($requestBodyAry['id_category']);
            
            if (empty($username) || empty($email)   || empty($password) ||
                empty($about)    || empty($founded) || empty($avatar)   ||
                empty($country)  || empty($city)    || empty($address)  ||
                empty($id_category)) {
                return $self->returnErrorResponse("Empty fields");
            }
            
            $checkUniqueName = $app['conversadb']->checkUserNameIsUnique($username);
            
            if (!$checkUniqueName) {
                return $self->returnErrorResponse("Name is already taken.");
            }
            
            if( !\Conversa\Utils::checkEmailIsValid($email) ){
                return $self->returnErrorResponse("Email is not valid");
            }
            
            $checkUniqueEmail = $app['conversadb']->checkEmailIsUnique($email);

            if (!$checkUniqueEmail) {
                return $self->returnErrorResponse("Email is already taken.");
            }
            
            $created = $app['conversadb']->createBusiness(
              $username, $email, $password, $about, $founded, 'online',
              $avatar, 'thumb_avatar', 3, $country,$city,$address,
              $id_category);
            
            return json_encode($created);
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
        $controllers->post('/updateBusiness', function (Request $request) use ($app,$self) {  
            
            $currentUser = $app['currentUser'];
            $userData    = $request->getContent();

            if(!$self->validateRequestParams($userData,array(
                'action', 'value'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($userData,true);
            $action = intval($requestBodyAry['action']);
            $value  = trim($requestBodyAry['value']);

            if($action != 1 && $action != 2) {
                if( empty($value) ) {
                    return $self->returnErrorResponse("Nuevo valor no puede estar vacio");
                }
            }

            if($action < 1 || $action > 5) {
                return $self->returnErrorResponse("Actualización no encontrada.");
            }

            $result = $app['conversadb']->updateBusinessAppData($currentUser['_id'],$action,$value,$currentUser['token']);

            return json_encode($result);
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
    }

    /**
     * Función para encontrar un negocio por <p>
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
        $controllers->get('/findBusiness/{type}/{value}', function ($type,$value) use ($app,$self) {

            if(empty($type) || empty($value)){
                return $self->returnErrorResponse("Faltan parámetros para realizar búsqueda.");
            }

            $currentUser = $app['currentUser'];
            $value = urldecode($value);

            switch ($type){
                case "id":
                    $userIds = explode(",",$value);
                    if(count($userIds) == 1) {
                        $result = $app['conversadb']->findUserById($value,true,true,0);
                    }
                    break;
                case "contacts":
                    $result = $app['conversadb']->findContactsById($value,BUSINESS_TYPE,$currentUser['token']);
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
        $controllers->get('/GetAvatarFileIdBusiness/{user_id}', function ($user_id) use ($app,$self) {

            if(empty($user_id)){
                return $self->returnErrorResponse("insufficient params");
            }

            $result = $app['conversadb']->getAvatarFileIdForBusiness($user_id);

            return json_encode($result);
        })->before($app['beforeApiGeneral']);
    }
    
    /**
     * Funciones para estadisticas de negocio
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers
     */
    private function setupStatisticsMethod($self,$app,$controllers){
        $controllers->post('/allStatistics', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $id          = $currentUser['_id'];
            $pushId      = $currentUser['push_id'];

            $result = $app['conversadb']->getBusinessStatistics($id,$pushId);

            return json_encode($result);
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
    }
    
    /**
     * Funciones para mensajes de negocio
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers
     */
    private function setupAutomateMethod($self,$app,$controllers){
        $controllers->post('/setAutoReply', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $requestBody = $request->getContent();

            if(!$self->validateRequestParams($requestBody,array(
                'push_id'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($requestBody,true);
            $pushId = trim($requestBodyAry['push_id']);
                
                
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        
        $controllers->post('/setKeywordsReply', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
                
                
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        
        $controllers->post('/setFirstMessage', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $requestBody = $request->getContent();

            if(!$self->validateRequestParams($requestBody,array(
                'push_id'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($requestBody,true);
            $pushId = trim($requestBodyAry['push_id']);

        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
    }
    
    private function setupLocationMethod($self,$app,$controllers) {
        $controllers->post('/businessLocation', function (Request $request) use ($app,$self) {  
            
            $currentUser = $app['currentUser'];
            $userData    = $request->getContent();

            if(!$self->validateRequestParams($userData,array(
                'action', 'value'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($userData,true);
            $action = intval($requestBodyAry['action']);
            $value  = trim($requestBodyAry['value']);

            if($action < 1 || $action > 2) {
                return $self->returnErrorResponse("Opcion no encontrada.");
            }

            $result = $app['conversadb']->addRemoveLocation($currentUser['_id'],$action,$value,$currentUser['token']);

            return json_encode($result);
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
    }
    
}