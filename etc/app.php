<?php

/*
 * This file is part of the Silex framework.
 *
 * Copyright (c) 2013 clover studio official account
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

error_reporting( E_ALL );
ini_set( "display_errors", 1 );
date_default_timezone_set("GMT");

require_once __DIR__.'/../vendor/autoload.php';
require_once __DIR__.'/../etc/constants.php';
require_once __DIR__.'/../config/init.php';
require_once __DIR__.'/../etc/utils.php';

use Silex\Provider\MonologServiceProvider;
use Silex\Provider\SwiftmailerServiceProvider;
use Monolog\Handler\NullHandler;

$app = new Silex\Application(isset($dependencies) ? $dependencies : array());
$app['debug'] = true;

// register providers
/**
 * Para cargar un proveedor de servicio y así poder utilizarlo, debes
 * registrarlo primero en la aplicación 
 */
// logging  
$app->register(new MonologServiceProvider(), array(
    'monolog.logfile' => __DIR__.'/../logs/debug.log',
));

if(!ENABLE_LOGGING){
    $app['monolog.handler'] = function () use ($app) {
        return new NullHandler();
    };
}
   
$app->register(new Silex\Provider\DoctrineServiceProvider(), array(
    'db.options' => array (
            'driver'    => 'pdo_mysql',
            'host'      => MySQL_HOST,
            'dbname'    => MySQL_DBNAME,
            'user'      => MySQL_USERNAME,
            'password'  => MySQL_PASSWORD,
            'charset'   => 'utf8'
    )
));


$app->register(new Conversa\Provider\ConversaDbServiceProvider(), array());

$app->register(new SwiftmailerServiceProvider());
$app->register(new Conversa\Provider\TokenCheckerServiceProvider());
$app->register(new Silex\Provider\TwigServiceProvider(), array(
    'twig.path' => __DIR__.'/../src/Conversa/Views',
));

$app->register(new Silex\Provider\SessionServiceProvider(), array());

$app->register(new Conversa\Provider\PushNotificationProvider(), array(
    'pushnotification.options' => array (
            'GCMAPIKey'    => GCM_API_KEY,
            'APNProdPem'   => __DIR__.'/../'.APN_PROD_CERT_PATH,
            'APNDevPem'    => __DIR__.'/../'.APN_DEV_CERT_PATH
    )
));

/**
 * Estos middlewares solo se ejecutan para las peticiones de tipo master.
 * Esto significa que no se tienen en cuenta en las sub-peticiones que
 * se crean para realizar los forwards.
 * 
 * El middleware de aplicación before te permite modificar el objeto 'Request',
 * en este caso el objeto 'app', antes de que se ejecute el controlador.
 * 
 * Esto significa que un servicio no deberia ser instanciado hasta que sea
 * necesario.
 */
$app['beforeApiGeneral'] = $app->share(function () use ($app) {
    return new Conversa\Middleware\APIGeneralBeforeHandler(
        $app['conversadb'],
        $app['logger'],
        $app
    );
});

$app['adminBeforeTokenChecker'] = $app->share(function () use ($app) {
    return new Conversa\Middleware\AdminChecker($app);
});

//Para la aplicación
/**
 * Antes de poder utilizar un proveedor de controladores debes importar
 * o "montar" los controladores bajo una determinada ruta
 */
$app->mount('/api/', new Conversa\Controller\ServerListController());
$app->mount('/api/', new Conversa\Controller\SendPasswordController());
$app->mount('/api/', new Conversa\Controller\ReportController());
$app->mount('/api/', new Conversa\Controller\FileController());
$app->mount('/api/', new Conversa\Controller\SearchController());
$app->mount('/api/', new Conversa\Controller\CategoryController());
$app->mount('/api/', new Conversa\Controller\BusinessController());
$app->mount('/api/', new Conversa\Controller\UserController());
$app->mount('/api/', new Conversa\Controller\UsersManagementController());
$app->mount('/api/', new Conversa\Controller\MessageController());
$app->mount('/api/', new Conversa\Controller\AsyncTaskController());
$app->mount('/page/', new Conversa\Controller\PasswordResetController());
//Para el servidor [Administrador]
$app->mount('/', new Conversa\Controller\Web\Installer\InstallerController());
$app->mount('/admin',  new Conversa\Controller\Web\Admin\LoginController());
$app->mount('/admin/', new Conversa\Controller\Web\Admin\BusinessController());
$app->mount('/admin/', new Conversa\Controller\Web\Admin\UserController());
$app->mount('/admin/', new Conversa\Controller\Web\Admin\CategoryController());
$app->mount('/admin/', new Conversa\Controller\Web\Admin\EmoticonController());
$app->mount('/admin/', new Conversa\Controller\Web\Admin\ServerController());
//Para el servidor [Cliente]
$app->mount('/client/', new Conversa\Controller\Web\Client\LoginController());
$app->mount('/client/', new Conversa\Controller\Web\Client\MainController());