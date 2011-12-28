--- 
layout: post
title: Organize Your Project like a Pro with PHP Namespaces
category: php
excerpt: PHP took a huge step forward in June 2009 with the release of version 5.3.  It wasn't quite as big of a change as version 5.0, but the release did introduce a number of new language features including namespaces -- an addition that can dramatically improve the way you organize your PHP in an object oriented paradigm. [...]
date: 2010-04-16 20:51:26 -04:00
legacy_id: http://prod.epixa.com/?p=29
---

Organize Your Project like a Pro with PHP Namespaces
====================================================

PHP took a huge step forward in June 2009 with the release of version 5.3.  It wasn't quite as big of a change as version 5.0, but the release did introduce a number of new language features including [namespaces][php-namespaces] -- an addition that can dramatically improve the way you organize your PHP in an object oriented paradigm.

[php-namespaces]: http://php.net/namespace

Anyone who's written code in Java, C++, or for any language in ASP.NET has had the pleasure of working with them, but we PHP developers have had to settle with emulating namespaces by defining long class prefixes.

Prefixes serve their primary purpose well: when used correctly, they will ensure that your class names do not have naming conflicts.  Unfortunately, they are long and pedantic, and provide no additional benefits.  Take, for example, the following class name: *Zend_Service_DeveloperGarden_Response_ConferenceCall_CreateConferenceResponseType* which can be found in [Zend Framework][zf].  At 81 characters, the name of this class by itself breaks the [recommended line length][zf-linelength] in Zend's own coding standard, and it is not even the longest class name in the framework!

[zf]: http://framework.zend.com
[zf-linelength]: http://framework.zend.com/manual/en/coding-standard.php-file-formatting.html#coding-standard.php-file-formatting.max-line-length

Namespaces provide other benefits than shorter class names, though.  Consider the following:

{% highlight php %}
<?php
namespace Epixa\\Service;

use Epixa\\Model\\ArticleModel,
    Epixa\\Model\\AuthorModel;

class ArticleService extends AbstractService
{
    /**
     * @param  string      $title
     * @param  AuthorModel $author
     * @return ArticleModel
     */
    public function create($title, AuthorModel $author)
    {
        $article = new ArticleModel();
        $article->title = $title;
        $article->author = $author;
        return $article;
    }
}
{% endhighlight %}

The namespace declaration immediately gives you a clear indication of what type of class is being declared -- a service within the Epixa library.

Along with simply declaring a namespace, the file then uses other namespaces.  In this particular case, I chose to import the specific classes ArticleModel and AuthorModel.  I could have simply used the Epixa\Model namespace, and then I would be able to instantiate any models within the namespace, but importing the specific models that I plan to use is a clear way to define class dependencies.

At this point, we haven't even declared the class, yet we already know what type of class it will be and what dependencies it will have.  Throughout the rest of the class declaration and definition, the concise class names are used.  Long, ugly prefixes are left in the dust, and the code is cleaner and clearer as a result.

But Court, it'll be *forever* until the community adopts PHP 5.3!
-----------------------------------------------------------------
While this sentiment might have been true for past releases of PHP, developers finally seem to be coming around to the notion that software drives the community forward.  When software increases its requirements, server administrators *will* follow suit.

In less than a year, industry-leading frameworks such as [Zend Framework][zf2-53] and [Symfony][symfony2-53] have decided to utilize these new features to such an extent that 5.3 will be a minimum requirement.  The Doctrine team is well into its development roadmap which includes a new [minimum requirement of PHP 5.3][doctrine2-53]; they have already slated an [end-of-life date][doctrine1-eol] for their 1.x branch and are taking the release of PHP 5.3 not as a challenge but as an opportunity to radically improve their codebase.

[zf2-53]: http://framework.zend.com/wiki/display/ZFDEV2/Zend+Framework+2.0+Roadmap
[symfony2-53]: http://www.symfony-project.org/blog/2009/10/27/why-will-symfony-2-0-finally-use-php-5-3
[doctrine2-53]: http://www.doctrine-project.org/documentation/manual/2_0/en/introduction#requirements
[doctrine1-eol]: http://www.doctrine-project.org/blog/doctrine-future-roadmap

Don't be left in the dust; the PHP community is moving forward with version 5.3, and an [easy upgrade path][php-upgradepath] means you can start benefiting from incredible language features such as namespaces immediately.

[php-upgradepath]: http://www.php.net/manual/en/migration53.incompatible.php