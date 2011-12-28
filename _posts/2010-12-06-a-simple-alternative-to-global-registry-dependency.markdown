--- 
layout: post
title: A Simple Alternative to Global Registry Dependency
category: php
excerpt: This is where many developers (and frameworks) turn to a global registry.  During the bootstrap process, they will configure a database adapter and store it in a singleton registry, and then their service object would retrieve the adapter from the registry.  This gives you flexibility when configuring and setting your adapter, and it allows you to instantiate a new service without having to explicitly set commonly used dependencies, but you are ultimately just replacing one hardcoded object call with another.  This means you are still limited in your ability to unit test the class properly, and you will have a difficult time debugging if you ever need to find out exactly when and where your database adapter was configured [...]
date: 2010-12-06 12:03:12 -05:00
legacy_id: http://epixa.com/?p=303
---

A Simple Alternative to Global Registry Dependency
==================================================

Anyone that has written object oriented code has had to use one class from within another class.  The quick and dirty way to implement this is to simply hardcode the object instantiation within the current class, but this can cause you more hassle in the long run.  Unfortunately, this method provides you with no means of overriding or changing that dependency on the fly, so future modifications and testing suffer.

The obvious solution to this hard-coding issue is to instead rely on objects being explicitly passed via a constructor and/or mutators.  If your service requires a database adapter, create a <strong>setDbAdapter()</strong> method and whenever you instantiate a new service object, pass in the adapter.  This solution provides an incredible amount of flexibility, but it does force you to set an adapter on every single service instantiation.  For most applications, only one database adapter will ever be required, so it is tedious at best to pass in the adapter to each and every service.

This is where many developers (and frameworks) turn to a global registry.  During the bootstrap process, they will configure a database adapter and store it in a singleton registry, and then their service object would retrieve the adapter from the registry.  This gives you flexibility when configuring and setting your adapter, and it allows you to instantiate a new service without having to explicitly set commonly used dependencies, but you are ultimately just replacing one hardcoded object call with another.  This means you are still limited in your ability to unit test the class properly, and you will have a difficult time debugging if you ever need to find out exactly when and where your database adapter was configured.

The Simple Solution
-------------------
Use static methods to set a default database adapter for all services that need it but still allow database adapters to be set explicitly.  In your bootstrap process, you configure your database adapter just like you would normally, then you set the adapter as the "default" adapter for all services.  The service should have a <strong>getDbAdapter()</strong> method that pulls either the adapter set on that instance or, if there is no adapter set, it uses the default adapter instead.

This is what your abstract service could look like (adapted from my [doctrine2 entity manager service][doctrine-service]):

[doctrine-service]: https://github.com/epixa/Epixa/blob/master/library/Epixa/Service/AbstractDoctrineService.php

{% highlight php %}
<?php
namespace Epixa\\Service;

use Epixa\\Exception\\ConfigException,
    Zend_Db_Adapter_Abstract as DbAdapter;

abstract class AbstractDbService
{
    protected $dbAdapter = null;

    protected static $defaultDbAdapter = null;

    
    /**
     * Set the default database adapter for all database services
     * 
     * @param DbAdapter $dbAdapter
     */
    public static function setDefaultDbAdapter(DbAdapter $dbAdapter)
    {
        self::$defaultDbAdapter = $dbAdapter;
    }

    /**
     * Get the default database adapter for all database services
     * 
     * @return DbAdapter
     * @throws ConfigException If no default database adapter is set
     */
    public static function getDefaultDbAdapter()
    {
        if (self::$defaultDbAdapter === null) {
            throw new ConfigException('No default database adapter configured');
        }

        return self::$defaultDbAdapter;
    }

    /**
     * Set the database adapter for this service
     * 
     * @param  DbAdapter $dbAdapter
     * @return AbstractDbService *Fluent interface*
     */
    public function setDbAdapter(DbAdapter $dbAdapter)
    {
        $this->dbAdapter = $dbAdapter;
        
        return $this;
    }

    /**
     * Get the database adapter for this service
     *
     * If no database adapter is set, set it to the default database adapter.
     *
     * @return DbAdapter
     */
    public function getDbAdapter()
    {
        if ($this->dbAdapter === null) {
            $this->setDbAdapter(self::getDefaultDbAdapter());
        }

        return $this->dbAdapter;
    }
}
{% endhighlight %}

Then, in your bootstrap, you would just need to set the default adapter:

{% highlight php %}
<?php

use Epixa\\Application\\Bootstrap as BaseBootstrap,
    Epixa\\Service\\AbstractDbService as DbService;

class Bootstrap extends BaseBootstrap
{
    /**
     * Set the default database adapter for database services
     */
    public function _initDbServices()
    {
        $db = $this->bootstrap('db')->getResource('db');
        DbService::setDefaultDbAdapter($db);
    }
}
{% endhighlight %}

This code is adhering to Zend Framework's bootstrapping implementation, but the premise is universal: set up your database adapter, and set it as the default on the abstract service.  After that is done, any class that extends AbstractDbService will have access to the database adapter.  However, if they needed to have their own database adapter set (either for unit testing purposes or if they happened to need to access another database), you can do so on an individual basis.  In either case, the way you access the database adapter within your service remains unchanged.

And that's it!  Go ahead and mock your dependencies for unit testing or throw around different database adapters at your pleasure.

Ok, ok...  That isn't entirely it.

There is One Large Caveat
-------------------------
If your objects rely on a large [variable] number of dependencies, a single abstract class might not do the trick.  My services generally do not require more than an entity manager and an ACL object, and I imagine many developers will be in a similar boat.  That said, this is not the best solution out there for handling a lot of dependencies.  If this is not sufficient for your needs, consider a more robust system such as [Symfony's dependency injection framework][symfony-di].

[symfony-di]: http://components.symfony-project.org/dependency-injection/

A Final Note
------------
With the addition of [traits][traits] in the PHP trunk, this method of setting defaults for dependencies will actually be that much more powerful.  Instead of having to deal with a single abstract class, each dependency can be managed by a single trait, and your objects will be able to pick and choose whichever traits they need.  Neat, eh?

[traits]: http://wiki.php.net/rfc/horizontalreuse