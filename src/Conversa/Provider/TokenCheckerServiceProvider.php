<?php
namespace Conversa\Provider;

use Conversa\Middleware\TokenChecker;
use Silex\Application;
use Silex\ServiceProviderInterface;

class TokenCheckerServiceProvider implements ServiceProviderInterface {
    
    public function register(Application $app) {
        if (!isset($app['beforeTokenChecker'])) {
            $app['beforeTokenChecker'] = $app->share(function () use ($app) {
                return new TokenChecker(
                    $app['conversadb'],
                    $app['logger'],
                    $app
                );
            });
        }
    }

    public function boot(Application $app){}
}
