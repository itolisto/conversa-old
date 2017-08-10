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

class ServerListController extends ConversaBaseController {
    
    public function connect(Application $app) {
        $controllers = $app['controllers_factory'];
        $self = $this;

        $controllers->get('/servers', function (Request $request) use ($app,$self) {
            $serverList = $app['conversadb']->findAllServersWithoutId();
            
            return json_encode($serverList);
        })->before($app['beforeApiGeneral']);

        return $controllers;
    }
}