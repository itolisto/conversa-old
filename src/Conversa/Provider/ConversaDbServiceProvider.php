<?php
namespace Conversa\Provider;

use Silex\Application;
use Silex\ServiceProviderInterface;
use Conversa\Db\MySql;

class ConversaDbServiceProvider implements ServiceProviderInterface {
    
    public function register(Application $app) {
        $app['conversadb'] = $app->share(function () use ($app) {
            return new MySQL(
                $app['logger'],
                $app['db']
            );
        });
    }

    public function boot(Application $app){}
}
