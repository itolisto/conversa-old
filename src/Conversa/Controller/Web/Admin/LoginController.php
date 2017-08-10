<?php

/*
 * This file is part of the Silex framework.
 *
 * Copyright (c) 2013 clover studio official account
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Conversa\Controller\Web\Admin;

use Silex\Application;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Conversa\Controller\Web\ConversaWebBaseController;
use Symfony\Component\HttpFoundation\Cookie;

class LoginController extends ConversaWebBaseController {
    /**
     * Maneja las rutas     <p>
     *  @Route "/admin/login" ["/" se redirige] <p>
     *  @Route "/dashboard" <p>
     *  @Route "/logout"    <p>
     * 
     * También maneja la accion de "Enviar" para el
     * formulario.
     * 
     * @param Application $app
     * @return type
     */
    public function connect(Application $app) {
        $controllers = parent::connect($app);
        $self = $this;
    
        $controllers->get('/', function (Request $request) use ($app,$self) {
            return $app->redirect(ROOT_URL . '/admin/login');
        }); 
        
        $controllers->get('/login', function (Request $request) use ($app,$self) {
            if($self->checkLogin()) {
                $response = new RedirectResponse(ROOT_URL . "/admin/dashboard");
                return $response;
            } else {                
                $cookies = $request->cookies;  
                $username = $password = "";

                if ($cookies->has('username')) {
                    $username = $cookies->get('username');
                }

                if ($cookies->has('password')) {
                    $password = $cookies->get('password');
                }
                
                return $self->render('admin/login.twig', array(
                    'ROOT_URL' => ROOT_URL,
                    'formValues' => array(
                        'username'  => $username,
                        'password'  => $password,                   
                        'rememberChecked'  => '',                   
                    )
                ));
            }            
        });
        
        $controllers->post('/login', function (Request $request) use ($app,$self) {
            
            $self->setVariables();
            $username = $request->get('username');
            $password = $request->get('password');
            $remember = $request->get('remember');
            $rememberChecked = "";
            
            if(!empty($remember)) {
                $rememberChecked = "checked=\"checked\"";
            }
            
            $authData = $self->app['conversadb']->doConversaAdminAuth($username,md5($password));
            
            if(isset($authData['token'])) {
                $self->render('admin/login.twig', array(
                    'ROOT_URL' => ROOT_URL,
                    'formValues' => array(
                        'username'  => $username,
                        'password'  => $password,                   
                        'rememberChecked'  => $rememberChecked,                 
                    )
                ));

                $response = new RedirectResponse(ROOT_URL . "/admin/dashboard");
                
                if(!empty($remember)){
                    $response->headers->setCookie(new Cookie("username", $username));
                    $response->headers->setCookie(new Cookie("password", $password));
                }
                
                $app['session']->set('user', $authData);
                
                return $response;
            } else {
                $self->setErrorAlert('Login no valido');
                
                return $self->render('admin/login.twig', array(
                    'ROOT_URL'              => ROOT_URL,
                    'formValues'            => array(
                        'username'        => $username,
                        'password'        => "",
                        'rememberChecked' => "",
                )));
            }            
        });
        
        $controllers->get('/dashboard', function (Request $request) use ($app,$self) {
            
            $self->setVariables();
            
            $countUsers = $self->app['conversadb']->findUserCount();
            $countMessages = $self->app['conversadb']->getMessageCount();
            $countLastLoginedUsers = $self->app['conversadb']->getLastLoginedUsersCount();

            return $self->render('admin/dashboard.twig', array(
                'countUsers' => $countUsers,
                'countMessages' => $countMessages,
                'countLastLoginedUsers' => $countLastLoginedUsers
            ));
            
                        
        })->before($app['adminBeforeTokenChecker']);
        
        $controllers->get('/logout', function (Request $request) use ($app,$self) {
            
            $app['session']->remove('user');
            $response = new RedirectResponse("login");
            
            return $response;        
        });
        
        return $controllers;
    }
    
}
