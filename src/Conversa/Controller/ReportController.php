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
use Symfony\Component\HttpFoundation\Request;

class ReportController implements ControllerProviderInterface {
    
    public function connect(Application $app) {
        $controllers = $app['controllers_factory'];

        // check unique controller
        $controllers->get('/reportViolation', function (Request $request) use ($app) {
            $documentId = $request->get('document_id');

            try{
                if(SEND_EMAIL_METHOD == EMAIL_METHOD_LOCALSMTP){
                    $message = \Swift_Message::newInstance()
                        ->setSubject("Convera Violation Report")
                        ->setFrom(EMAIL_LOCAL)
                        ->setTo(EMAIL_LOCAL)
                        ->setBody($documentId);

                    $mailer = \Swift_Mailer::newInstance();
                    $mailer->send($message);
                }

                if(SEND_EMAIL_METHOD == EMAIL_METHOD_GMAIL){
                    $transport = \Swift_SmtpTransport::newInstance('smtp.gmail.com', 465, 'ssl')
                        ->setUsername(EMAIL_GMAIL)
                        ->setPassword(GMAIL_PASSWORD)
                        ->setAuthMode('login');

                    $message = \Swift_Message::newInstance($transport)
                        ->setSubject("Conversa Violation Report")
                        ->setFrom(EMAIL_GMAIL)
                        ->setTo(EMAIL_GMAIL)
                        ->setBody($documentId);

                    $mailer = \Swift_Mailer::newInstance($transport);
                    $mailer->send($message);
                }
            }catch(\Exception $e){
                return $e->getMessage();
            }
                    
            return 'OK';
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);

        return $controllers;
    }
}
