<?php

/*
 * This file is part of the Silex framework.
 *
 * Copyright (c) 2013 clover studio official account
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Conversa\Controller;

use Silex\Application;
use Symfony\Component\HttpFoundation\Request;

class UsersManagementController extends ConversaBaseController {

    public function connect(Application $app) {
        $controllers = $app['controllers_factory'];
        $self = $this;

        $this->setupBlockUserMethod($self,$app,$controllers);
        $this->setupContactsMethod($self,$app,$controllers);

        return $controllers;
    }

    /**
     * Función para actualizar la información de usuario
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers
     */
    private function setupBlockUserMethod($self,$app,$controllers){
        $controllers->post('/blockUser', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $requestBody = $request->getContent();

            if(!$self->validateRequestParams($requestBody,array(
                'to_user_id', 'to_user_type'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($requestBody,true);
            $targetId       = trim($requestBodyAry['to_user_id']);
            $userId         = $currentUser['_id'];
            $targetType     = trim($requestBodyAry['to_user_type']);
            $userType       = $currentUser['type'];

            $result = $app['conversadb']->blockContact($userId,$targetId,$userType,$targetType,1);

            if($result == 1) {
                return json_encode(array('success' => true));
            } else {
                return $self->returnErrorResponse("No se ha podido bloquear contacto!");
            }
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        
        $controllers->post('/unblockUser', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $requestBody = $request->getContent();

            if(!$self->validateRequestParams($requestBody,array(
                'to_user_id', 'to_user_type'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($requestBody,true);
            $targetId       = trim($requestBodyAry['to_user_id']);
            $userId         = $currentUser['_id'];
            $targetType     = trim($requestBodyAry['to_user_type']);
            $userType       = $currentUser['type'];

            $result = $app['conversadb']->blockContact($userId,$targetId,$userType,$targetType,0);

            if($result == 1) {
                return json_encode(array('success' => true));
            } else {
                return $self->returnErrorResponse("No se ha podido desbloquear contacto!");
            }
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
    }
    
    /**
     * Funciones para agregar y remover contacto
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers
     */
    private function setupContactsMethod($self,$app,$controllers){
        $controllers->post('/addContact', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $requestBody = $request->getContent();

            if(!$self->validateRequestParams($requestBody,array(
                'to_user_id'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($requestBody,true);
            $businessId     = trim($requestBodyAry['to_user_id']);
            $userId         = $currentUser['_id'];

            $result = $app['conversadb']->addContact($userId,$businessId);
            if($result == 1) {
                $userData = $app['conversadb']->findBusinessByIdApp($businessId);
            } else {
                if ($result == 2) {
                    return $self->returnErrorResponse("Estas bloqueado");
                } else {
                    return $self->returnErrorResponse("No se ha podido agregar contacto!");
                }
            }

            return json_encode($userData);
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        /* ********************************************************************** */
        $controllers->post('/removeContact', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $requestBody = $request->getContent();

            if(!$self->validateRequestParams($requestBody,array(
                'business_id'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($requestBody,true);
            $businessId     = trim($requestBodyAry['business_id']);

            $result = $app['conversadb']->removeContact($currentUser['_id'],$businessId);

            if($result == 1) {
                return json_encode(array('success' => true));
            } else {
                return $self->returnErrorResponse("No se ha podido eliminar contacto!");
            }

            return json_encode(array('success' => true));
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        /* ********************************************************************** */
        /* ********************************************************************** */
        $controllers->post('/addContactBusiness', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $requestBody = $request->getContent();

            if(!$self->validateRequestParams($requestBody,array(
                'to_user_id'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($requestBody,true);
            $id     = $currentUser['_id'];
            $toId   = trim($requestBodyAry['to_user_id']);
            $pushId = $currentUser['push_id'];

            $result = $app['conversadb']->addContactBusiness($id,$toId,$pushId);

            if($result == 1) {
                $userData = $app['conversadb']->findUserById($toId,true,true,0);
            } else {
                if ($result == 2) {
                    return $self->returnErrorResponse("Estas bloqueado");
                } else {
                    return $self->returnErrorResponse("No se ha podido agregar contacto!");
                }
            }

            return json_encode($userData);
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        
        $controllers->post('/removeContactBusiness', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $requestBody = $request->getContent();

            if(!$self->validateRequestParams($requestBody,array(
                'to_user_id'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($requestBody,true);
            $id     = $currentUser['_id'];
            $toId   = trim($requestBodyAry['to_user_id']);
            $pushId = $currentUser['push_id'];

            $result = $app['conversadb']->removeContactBusiness(
                    $toId,$id,$pushId);

            if($result == 1) {
                return json_encode(array('success' => true));
            } else {
                return $self->returnErrorResponse("No se ha podido eliminar contacto!");
            }
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
    }
}