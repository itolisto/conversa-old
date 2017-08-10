<?php

/*
 * This file is part of the Silex framework.
 *
 * Copyright (c) 2013 clover studio official account
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Conversa\Controller\Web\Client;

use Silex\Application;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Conversa\Controller\Web\ConversaWebBaseController;
use Conversa\Utils;
use Guzzle\Http\Client;

class LoginController extends ConversaWebBaseController
{

    public function connect(Application $app)
    {
        parent::connect($app);
        
        $controllers = $app['controllers_factory'];
        $self = $this;
    
        $controllers->get('/', function (Request $request) use ($app,$self) {
            return $app->redirect(ROOT_URL . '/client/login');   
        }); 
        
        $controllers->get('/login', function (Request $request) use ($app,$self) {
            
            $cookies = $request->cookies;
            
            $username = "";
            $password = "";

            if ($cookies->has('username')) {
                $username = $cookies->get('username');
            }
    
            if ($cookies->has('password')) {
                $password = $cookies->get('password');
            }
    
            return $self->render('client/login.twig', array(
                'ROOT_URL' => ROOT_URL,
                'formValues' => array(
                    'username'  => $username,
                    'password'  => $password,                   
                    'rememberChecked'  => '',                   
                )
            ));
                        
        });
        
        $controllers->post('/login', function (Request $request) use ($app,$self) {
            
            $self->setVariables();

            $registBtn = $request->get('regist');
            if(!empty($registBtn)){
                return new RedirectResponse("regist");
            }
            
            $username = $request->get('username');
            $password = $request->get('password');
            $remember = $request->get('remember');
            $rememberChecked = "";
            
            if(!empty($remember)){
                $rememberChecked = "checked=\"checked\"";
            }
            
            $authData = $self->app['conversadb']->doConversaAuth($username,md5($password));
            $authData = json_decode($authData,true);
            
            if(isset($authData['token'])){
                
                $html = $self->render('client/login.twig', array(
                    'ROOT_URL' => ROOT_URL,
                    'formValues' => array(
                        'username'  => $username,
                        'password'  => $password,                   
                        'rememberChecked'  => $rememberChecked,                 
                    )
                ));

                $response = new RedirectResponse(ROOT_URL . "/client/main");
                $app['session']->set('user', $authData);
                return $response;
                
            }else{
                
                $self->setErrorAlert($self->language['messageLoginFailed']);
                
                return $self->render('client/login.twig', array(
                    'ROOT_URL' => ROOT_URL,
                    'formValues' => array(
                        'username'  => $username,
                        'password'  => $password,                   
                        'rememberChecked'  => $rememberChecked,                 
                    )
                ));
                
            }
            
                        
        });
        
        $controllers->get('/logout', function (Request $request) use ($app,$self) {
            
            $app['session']->remove('user');
            $response = new RedirectResponse("login");
            
            return $response;        
        });
        
        $controllers->get('/regist', function (Request $request) use ($app,$self) {
            
            $cookies = $request->cookies;
            
            $email = "";
            $username = "";
            $password = "";

            return $self->render('client/regist.twig', array(
                'ROOT_URL' => ROOT_URL,
                'formValues' => array(
                    'username'  => $username,
                    'password'  => $password,                   
                    'email'  => $email                  
                )
            ));
                        
        });

        $controllers->post('/regist', function (Request $request) use ($app,$self) {
            
            $self->setVariables();

            $username = $request->get('username');
            $password = $request->get('password');
            $email = $request->get('email');

            $loginBtn = $request->get('login');
            if(!empty($loginBtn)){
                return new RedirectResponse("login");
            }
            
            // validation
            $errorMessage = "";
            if(empty($username)){
                $errorMessage = $self->language['messageValidationErrorEmptyUserName'];
            }
            else if(empty($email)){
                $errorMessage = $self->language['messageValidationErrorEmptyEmail'];
            }
            else if(empty($password)){
                $errorMessage = $self->language['messageValidationErrorEmptyPassword'];
            }
            
            if(empty($errorMessage)){
                if (!Utils::checkEmailIsValid($email)) {
                    $errorMessage = $self->language['messageValidationErrorInvalidEmail'];
                }
            }
            
            if(empty($errorMessage)){
                if (!Utils::checkPasswordIsValid($password)) {
                    $errorMessage = $self->language['messageValidationErrorInvalidPassword'];
                }
            }            

            if(empty($errorMessage)){
                $check = $app['conversadb']->findUserByName($username);
                if(!empty($check['_id']))
                    $errorMessage = $self->language['messageValidationErrorUserNameNotUnique'];
            }            

            if(empty($errorMessage)){
                $check = $app['conversadb']->findUserByEmail($email);
                if(!empty($check['_id']))
                    $errorMessage = $self->language['messageValidationErrorUserEmailNotUnique'];
            }            

            if(!empty($errorMessage)){
                $self->setErrorAlert($errorMessage);
            }else{
                
                //AGREGAR MAS DATOS A FORMULARIO
                
                $newUserId = $app['conversadb']->createUser(
                    $username,
                    $email,
                    md5($password)
                );
                
                if($newUserId != 0) {
                    $authData = $self->app['conversadb']->doConversaAuth($email,md5($password));
                    $authData = json_decode($authData,true);

                    $response = new RedirectResponse("main");
                    $app['session']->set('user', $authData);
                    return $response;
                } else {
                    $errorMessage = $self->language['messageUserAddedError'];
                    $self->setErrorAlert($errorMessage);
                }
            }
            
            
            return $self->render('client/regist.twig', array(
                'ROOT_URL' => ROOT_URL,
                'formValues' => array(
                    'username'  => $username,
                    'password'  => $password,                   
                    'email'  => $email                  
                )
            ));
            
        });
    
        $controllers->get('/resetPassword', function (Request $request) use ($app,$self) {
            
            $self->setVariables();
    
            return $self->render('client/resetpassword.twig', array(
                'ROOT_URL' => ROOT_URL,
                'formValues' => array(
                    'email'  => ''                 
                )
            ));
            
        });
        
        $controllers->post('/resetPassword', function (Request $request) use ($app,$self) {
            
            $self->setVariables();

            $email = $request->get('email');

            $loginBtn = $request->get('login');
            if(!empty($loginBtn)){
                return new RedirectResponse("login");
            }
            
            // validation
            $errorMessage = "";
            if(empty($email)){
                $errorMessage = $self->language['messageValidationErrorEmptyEmail'];
            }
            
            if(empty($errorMessage)){
                $check = $app['conversadb']->findUserByEmail($email);
                if(empty($check['_id']))
                    $errorMessage = $self->language['messageValidationEmailIsNotExist'];
            }            

            if(!empty($errorMessage)){
                $self->setErrorAlert($errorMessage);
            }else{
                
                // call api
                $client = new Client();
                $request = $client->get(LOCAL_ROOT_URL . "/api/resetPassword?email=" . $email);
                $response = $request->send();
                        
                $self->setInfoAlert($self->language['messageResetPasswordEmailSent']);
                
            }
            
            return $self->render('client/resetpassword.twig', array(
                'ROOT_URL' => ROOT_URL,
                'formValues' => array(
                    'email'  => $email                  
                )
            ));
                  
                        
        });
        
        return $controllers;
    }
    
}
