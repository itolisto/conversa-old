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

class SearchController extends ConversaBaseController {

    public function connect(Application $app) {
        $controllers = $app['controllers_factory'];
        $self = $this;

        $this->setupSearchMethod($self,$app,$controllers);

        return $controllers;
    }

    /**
     * Busca un negocio por ID o por nombre
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers
     */
    private function setupSearchMethod($self,$app,$controllers) {
        $controllers->post('/searchForBusinessById', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $requestBody = $request->getContent();

            if(!$self->validateRequestParams($requestBody,array(
                'name'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($requestBody,true);
            $target         = trim($requestBodyAry['name']);

            if($currentUser['type'] == USER_TYPE) {
                $result = $app['conversadb']->searchForBusiness($target,$currentUser['_id']);
            } else {
                $result = null;
            }

            if(!is_null($result)) {
                return json_encode($result);
            } else {
                return $self->returnErrorResponse("No se ha podido eliminar contacto!");
            }
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        
        //// CHANGE THIS TO 'searchForBusinessByCategory'
        $controllers->post('/searchForBusiness', function (Request $request) use ($app,$self) {
                
            $currentUser = $app['currentUser'];
            $requestBody = $request->getContent();

            if(!$self->validateRequestParams($requestBody,array(
                'name', 'category'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }

            $requestBodyAry = json_decode($requestBody,true);
            $target         = trim($requestBodyAry['name']);
            $category       = trim($requestBodyAry['category']);

            if($currentUser['type'] == USER_TYPE) {
                $result = $app['conversadb']->searchForBusinessByCategory($target,$currentUser['_id'],$category);
            } else {
                $result = null;
            }

            if(!is_null($result)) {
                return json_encode($result);
            } else {
                return $self->returnErrorResponse("No se ha podido eliminar contacto!");
            }
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
    }
}