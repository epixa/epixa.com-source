--- 
layout: post
title: The Best Models are Easy Models
category: php
excerpt: Models are one of the most important building blocks to any well-formed application, but a few common misconceptions persist throughout the development community that can make working with models excruciating.  A properly constructed model should not only be powerful, but it should be extremely easy to work with. [...]
date: 2010-05-05 22:48:47 -04:00
legacy_id: http://epixa.com/?p=112
---

The Best Models are Easy Models
===============================

Models are one of the most important building blocks to any well-formed application, but a few common misconceptions persist throughout the development community that can make working with models excruciating.  A properly constructed model should not only be powerful, but it should be extremely easy to work with.

While models do contain specific data, they are far more than simple data structures.  They should contain all logic possible to manage, manipulate, and validate the correctness of data as it is updated.  By treating your models as nothing more than a place to dump your data, you are doing yourself and your application a severe disservice; your business logic is going to be scattered throughout the rest of your application, and you will have a progressively more difficult time as you try to maintain and build upon your existing system.  Do not fall into the [anemic model][anemic-models] trap.

[anemic-models]: http://www.martinfowler.com/bliki/AnemicDomainModel.html

In addition, models should be independent of the data-access layer.  If I am modeling a blog article, the article should not know nor care to know whether it was created from a mysql database, an xml file, user input, or the divine spaghetti monster.  No matter how it was populated or where it was persisted, the blog article is a blog article, and that is all that is important.

To manage my data access, I am a huge proponent of [Doctrine 2][doctrine2].  Of which, one of my favorite features is that my models are completely decoupled from Doctrine itself.  This means there is no base model class that defines a ton of functionality for interacting with your data abstraction, so you have near endless flexibility when it comes to creating your models.  However, just because you are not *required* to extend a base record class does not mean that working with many of your models cannot be improved with some simple, abstract implementations.  Utilizing a simple abstract model and a few best practices can ensure your models remain incredibly versatile while still preserving the strict integrity of your data.

[doctrine2]: http://www.doctrine-project.org

Let's start with a simple blog article model:

{% highlight php %}
<?php
namespace Blog;

use Epixa\AbstractModel;

/**
 * @Entity
 * @Table(name="blog_article")
 */
class ArticleModel extends AbstractModel
{
    /**
     * @Id @Column(type="integer")
     * @GeneratedValue
     */
    protected $id;

    /**
     * @Column(type="string")
     */
    protected $title;

    /**
     * @Column(type="date")
     */
    protected $date;

    /**
     * @Column(type="text")
     */
    protected $content;

    /**
     * For demonstration purposes only
     */
    protected $_hiddenProperty;
}
{% endhighlight %}

In our AbstractModel, we will utilize php's magic methods to provide access to our entity properties in both a convenient and secure way.  All calls to retrieve a property's value will map through an appropriate accessor if one exists, and all attempts to set an entity property will map through an appropriate mutator if one exists.

{% highlight php %}
<?php
namespace Blog;

abstract class AbstractModel
{
    /**
     * Map a call to get a property to its corresponding accessor if it exists.
     * Otherwise, get the property directly.
     *
     * Ignore any properties that begin with an underscore so not all of our
     * protected properties are exposed.
     *
     * @param  string $name
     * @return mixed
     * @throws \LogicException If no accessor/property exists by that name
     */
    public function __get($name)
    {
        if ($name[0] != '_') {
            $accessor = 'get'. ucfirst($name);
            if (method_exists($this, $accessor)) {
                return $this->$accessor();
            }

            if (property_exists($this, $name)) {
                return $this->$name;
            }
        }

        throw new \LogicException(sprintf(
            'No property named `%s` exists',
            $name
        ));
    }

    /**
     * Map a call to set a property to its corresponding mutator if it exists.
     * Otherwise, set the property directly.
     *
     * Ignore any properties that begin with an underscore so not all of our
     * protected properties are exposed.
     * 
     * @param  string $name
     * @param  mixed  $value
     * @return void
     * @throws \LogicException If no mutator/property exists by that name
     */
    public function __set($name, $value)
    {
        if ($name[0] != '_') {
            $mutator = 'set'. ucfirst($name);
            if (method_exists($this, $mutator)) {
                $this->$mutator($value);
                return;
            }

            if (property_exists($this, $name)) {
                $this->$name = $value;
                return;
            }
        }

        throw new \LogicException(sprintf(
            'No property named `%s` exists',
            $name
        ));
    }

    /**
     * Map a call to a non-existent mutator or accessor directly to its
     * corresponding property
     *
     * @param  string $name
     * @param  array  $arguments
     * @return mixed
     * @throws \BadMethodCallException If no mutator/accessor can be found
     */
    public function __call($name, $arguments)
    {
        if (strlen($name) > 3) {
            if (strpos($name, 'set') === 0) {
                $property = lcfirst(substr($name, 3));

                $this->$property = array_shift($arguments);
                return $this;
            }

            if (0 === strpos($name, 'get')) {
                $property = lcfirst(substr($name, 3));

                return $this->$property;
            }
        }

        throw new \BadMethodCallException(sprintf(
            'No method named `%s` exists',
            $name
        ));
    }
}
{% endhighlight %}

With these simple methods, our protected entity properties are accessible like public properties, but individual models can ensure that their access and modification is still bound by filtering/validation through mutators and accessors.  Let's implement some of these in our article model:

{% highlight php %}
<?php
// ...
class ArticleModel extends AbstractModel
{
    // ...

    /**
     * Constructor
     * 
     * Set the date to right now
     */
    public function __construct()
    {
        $this->setDate('now');
    }

    /**
     * @throws \BadMethodCallException Every time
     */
    public function setId()
    {
        throw new \BadMethodCallException('Cannot set article id directly');
    }

    /**
     * Set the article title
     * 
     * @param  string $title
     * @return ArticleModel *Provides fluid interface*
     * @throws \InvalidArgumentException If title is less than 3 characters
     */
    public function setTitle($title)
    {
        $title = trim($title);

        if (strlen($title) < 3) {
            throw new \InvalidArgumentException('Title must be more than 3 chars');
        }

        $this->title = $title;

        return $this;
    }

    /**
     * Set the article date
     * 
     * @param  mixed $date
     * @return ArticleModel *Provides fluid interface*
     * @throws \InvalidArgumentException If invalid date is given
     */
    public function setDate($date)
    {
        if (is_int($date)) {
            $date = new \DateTime("@$date");
        } else if (is_string($date)) {
            $date = new \DateTime($date);
        } else if (!$date instanceof \DateTime) {
            throw new \InvalidArgumentException(sprintf(
                'Expecting string, int or DateTime but `%s` given',
                gettype($date)
            ));
        }

        $this->date = $date;

        return $this;
    }

    /**
     * Get the article date in a human readable format
     * 
     * @return string
     */
    public function getFormattedDate()
    {
        return $this->date->format('F j, Y');
    }
}
{% endhighlight %}

With that, our article model filters and validates incoming and outgoing data.  Our article date is set immediately upon instantiation, the title is always trimmed and its length validated, the date can be set by multiple different types of values but is always stored as a DateTime, and we can utilize a convenience accessor (even as a property) to get the date formatted as a string.

If you are the type of developer that insists on having 100% data integrity in your models at all times, you could take this filtering and validation one step further by passing all required fields as arguments in the constructor.  On the other hand, if you're like me you would abstract out the logic for handling data validation, so you could reuse the validation in forms that accept input from the user to populate your models and create a prePersist [lifecycle callback][doctrine2-lifecycle] (Doctrine only) that runs through the validation before a new model is persisted in the database.

[doctrine2-lifecycle]: http://www.doctrine-project.org/documentation/manual/2_0/en/events#lifecycle-callbacks

To finish this up, here are some ad hoc examples of code using the ArticleModel:

{% highlight php %}
<?php

$article = new Blog\ArticleModel();

$article->title = '   My Article Title ';
echo $article->title;
// outputs: My Article Title

$article->title = 'My';
// throws exception: Title must be more than 3 chars

$article->date = 'yesterday';
echo $article->formattedDate;
// outputs: May 5, 2010

echo $article->setContent('This is my content')->getContent();
// outputs: This is my content

$article->_hiddenProperty;
// throws exception: No property named `_hiddenProperty` exists
{% endhighlight %}


Other Resources about Models
----------------------------

* [Model Infrastructure - Matthew Weier O'Phinner][mwo-models]
* [Models in Zend Framework - Matthew Turland][elazar-models]

[mwo-models]: http://weierophinney.net/matthew/archives/202-Model-Infrastructure.html
[elazar-models]: http://matthewturland.com/2010/03/26/models-in-zend-framework/
