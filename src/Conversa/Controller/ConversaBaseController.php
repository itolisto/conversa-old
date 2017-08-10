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
use Silex\ControllerProviderInterface;
use Symfony\Component\HttpFoundation\Response;
use Guzzle\Http\Client;
use Guzzle\Plugin\Async\AsyncPlugin;

class ConversaBaseController implements ControllerProviderInterface {
    
    public $app = null;
    
    public function connect(Application $app) {
        $this->app   = $app;
        $controllers = $app['controllers_factory'];
        return $controllers;        
    }
    
    /**
     * Compara si los parametros requeridos están contenidos
     * dentro del cuerpo del primer parámetro
     * 
     * @param array $requestBody
     * @param array $requiredParams
     * @return boolean
     */
    public function validateRequestParams($requestBody,$requiredParams){
        $requestParams = json_decode($requestBody,true);

        if (!is_array($requestParams)) {
            return false;
        }

        foreach($requiredParams as $param){
            if (!isset($requestParams[$param])) {
                return false;
            }
        }
        
        return true;
    }

    public function returnErrorResponse($errorMessage,$httpCode = 500) {
        $arr  = array('message' => $errorMessage, 'error' => 'error');
        $json = json_encode($arr);
        return new Response($json, $httpCode);
    }
    
    public function doAsyncRequest($app,$request,$apiName,$params = null) {
        $client     = new Client();
        $json       = json_encode($params);
        $requestURL = LOCAL_ROOT_URL . "/api/{$apiName}?XDEBUG_SESSION_START=netbeans-xdebug";
        
        $app['monolog']->addDebug($requestURL);
        
        $client->addSubscriber(new AsyncPlugin());
        $request = $client->post($requestURL,array(),array('timeout' => 0, 'connect_timeout' => 0));
        $request->setBody($json,'application/json');
        $request->send();
    }
}