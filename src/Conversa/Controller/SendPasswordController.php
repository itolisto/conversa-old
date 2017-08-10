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

class SendPasswordController extends ConversaBaseController {
    
    public function connect(Application $app) {
        $controllers = $app['controllers_factory'];
        $self = $this;
        
        // check unique controller
        $controllers->post('/resetPassword', function (Request $request) use ($app,$self) {

            $requestBody = $request->getContent();
            
            if(!$self->validateRequestParams($requestBody,array(
                'email'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }
            
            $requestBodyAry = json_decode($requestBody,true);
            $email = trim($requestBodyAry['email']);
            
            if(empty($email) || !\Conversa\Utils::checkEmailIsValid($email) ) {
                return $self->returnErrorResponse("Email is not valid");
            }
            
            $user = $app['conversadb']->findUserByEmail($email);
                        
            if (isset($user['_id'])) {
                $resetCode = $app['conversadb']->addPassworResetRequest($user['us_id']);
                $resetPasswordUrl = ROOT_URL . "/page/resetPassword/" . $resetCode;
                $body = "Please reset password here {$resetPasswordUrl}";

                try{
                    if(SEND_EMAIL_METHOD == EMAIL_METHOD_LOCALSMTP) {
                        $message = \Swift_Message::newInstance()
                            ->setSubject("Conversa Reset Password")
                            ->setFrom(EMAIL_LOCAL)
                            ->setTo($user['email'])
                            ->setBody($body);
                        
                        $mailer = \Swift_Mailer::newInstance();
                        $mailer->send($message);
                    }
                    
                    if(SEND_EMAIL_METHOD == EMAIL_METHOD_GMAIL) {
//                        $transport = \Swift_SmtpTransport::newInstance('smtp.gmail.com', 465, 'ssl')
//                            ->setUsername(EMAIL_GMAIL)
//                            ->setPassword(GMAIL_PASSWORD)
//                            ->setAuthMode('plain');
//
//                        $message = \Swift_Message::newInstance()
//                            ->setSubject("Conversa Reset Password")
//                            ->setFrom(EMAIL_GMAIL)
//                            ->setTo($user['email'])
//                            ->setBody($body);
//                        
//                        $mailer = \Swift_Mailer::newInstance($transport);
//                        $mailer->send($message);
                        $mail = new \PHPMailer();
                        $mail->isSMTP();
                        $mail->SMTPDebug = 1;
                        $mail->SMTPAuth = true; 
                        $mail->SMTPSecure = 'ssl';
                        $mail->Host = 'smtp.gmail.com';
                        $mail->Port = 465;
                        $mail->isHTML(true);
                        $mail->Username = 'appconversa@gmail.com';                       
                        $mail->Password = 'GaQhikhPoBB0f';
                        $mail->setFrom('appconversa@gmail.com');
                        $mail->Subject = 'Conversa Password Recovery';
                        $mail->Body    = $body;
                        $mail->addAddress($user['email']);

                        if(!$mail->send()) { 
                           return $self->returnErrorResponse($mail->ErrorInfo);
                        }
                    }                   
                }catch(\Exception $e){
                    return $self->returnErrorResponse($e->getMessage());
                }
                
                $arr = array('ok' => true);
                return json_encode($arr);
            }else{
                $arr = array(ERROR => true);
                return json_encode($arr);
            }
        })->before($app['beforeApiGeneral']);
        
        return $controllers;
    }
}