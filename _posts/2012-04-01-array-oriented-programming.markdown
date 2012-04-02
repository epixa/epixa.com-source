---
layout: post
title: "A New Paradigm Rises to Save the Modern Web"
category: php
excerpt: To truly revolutionize the web as a whole, a new system or paradigm must allow users to incrementally update their existing apps and workflows. Fortunately, there is now a new paradigm that originated within the PHP community that is rapidly changing the way we develop web and mobile apps.  [...]
date: 2012-04-01 12:00:00 -05:00
---

A New Paradigm Rises to Save the Modern Web
==========================

This was my April Fools day post for 2012.  To clarify a few things:

* As far as I know, array-oriented programming is not a thing.  I sure hope it never becomes a thing.
* The code that I provided may have some cool components, but it is not good overall.  It is very inflexible and extremely fragile.  I broke it a half dozen times just trying to make simple changes, and it took me 10x longer to write than would be necessary in another coding style.
* Verbosity should not be a goal of any paradigm.  If you choose to be verbose with your code, so be it.  Good paradigms, like object-oriented and functional programming, empower you to make that sort of decision yourself.
* If you dig the usage of anonymous functions here, then I highly recommend that you try out some functional programming.  It is fun.
* The new array syntax in PHP 5.4 is rad as hell.
* No core developers were harmed in the making of this blog article.

April Fools!

*************

Programming on the web has come a long way since the wild-west early days of the 90s, and nowhere has this been more evident than in the PHP community.  The earliest "apps" made with PHP were little more than some odd scripting bits that helped web pioneers and hobbyists to more easily maintain their HTML websites.  At the turn of the century, larger, procedural PHP apps started to pop up that would eventually change the web as we knew it.  Less than a decade later, the widespread adoption of object-oriented programming throughout most web development communities had led to some of the most sophisticated triumphs of software engineering (or hackery) in history.

But just as procedural coding proved insufficient for developing the types of applications that the consumers of the web demanded, the usefulness of object-oriented programming is rapidly reaching its limits.  Object-oriented programming ultimately results in highly complex, bloated, and inconsistent code bases that cannot sustain the growing demand they will no doubt receive.  Once an object-oriented app reaches a certain mass, those problems begin to create cracks in its very foundation.

To free us from these constraints, some look to new systems that boast event-driven, functional foundations such as node.js.  Communities behind these systems make bold claims about the impact they will have on the web of tomorrow, but while this approach certainly has its benefits, it suffers from the very huge obstacle of being completely incompatible with their existing app architectures. To truly revolutionize the web as a whole, a new system or paradigm must allow users to incrementally update their existing apps and workflows.

Fortunately, there is now a new paradigm that originated within the PHP community that is rapidly changing the way we develop web and mobile apps.  Array-oriented programming (AOP) combines all of the structure of object-oriented systems with the ease-of-use and efficiency that could exist in procedural apps, and it does so in a highly consistent way.  Best of all, it can be done in any programming language that supports arrays, and it can be used to build entirely new apps or even incrementally refactored into existing apps regardless of whether they were procedural or object-oriented to begin with.

Array-oriented programming is based on one driving principle, *an entire program structure and flow is defined as an array*.  It really is as simple as it sounds.

AOP is not a new concept, but it is just now gaining traction in the web development community.  There are countless articles scattered across the web that go into great detail about the technical intricacies of this revolutionary paradigm, so I won't bore you by driving in all of those same points.  Instead, let's take a look at a complete array-oriented program:

{% highlight php %}
<?php
$app = array(
    'session' => array(),
    'request' => array(
        'method' => 'GET',
        'uri' => '',
        'data' => array()
    ),
    'response' => array(
        'body' => '',
        'headers' => array()
    ),
    'errors' => array(
        404 => function(&$request, &$response) {
            $response['body'] = '404 Not Found';
            $response['headers'][] = 'Status: 404';
        }
    ),
    'routes' => array(
        'GET /' => function(&$request, &$response, &$session) {
            $name = isset($session['name']) ? $session['name'] : 'World';
            ob_start();
            // not shown, but your standard php template
            include '../template/home.phtml';
            $response['body'] = ob_get_contents();
            ob_end_clean();
        },
        'POST /' => function(&$request, &$response, &$session) {
            if (isset($request['data']['name'])) {
                $session['name'] = $request['data']['name'];
            }
            $response['headers'][] = 'Location: /';
            $response['body'] = null;
        }
    ),
    'route' => null,
    'bootstrap' => array(
        'session' => function(&$app) {
            session_start();
            $app['session'] = &$_SESSION;
        },
        'request' => function(&$app) {
            if ($_SERVER['REQUEST_METHOD'] == 'POST') {
                $app['request']['is_post'] = true;
            }
            $app['request']['uri'] = '/' . trim($_SERVER['REQUEST_URI'], '/');
            $app['request']['method'] = strtoupper($_SERVER['REQUEST_METHOD']);
            $app['request']['data'] = $_REQUEST;
        },
        'router' => function(&$app) {
            $route = $app['request']['method'] . ' ' . $app['request']['uri'];
            if (!isset($app['routes'][$route])) {
                $app['route'] = $app['errors'][404];
                return;
            }

            $app['route'] = $app['routes'][$route];
        }
    ),
    'dispatch' => function(&$app) {
        $route = $app['route'];
        $route($app['request'], $app['response'], $app['session']);
    }
);

foreach ($app['bootstrap'] as $bootstrap) {
    $bootstrap($app);
}
$app['dispatch']($app);

foreach ($app['response']['headers'] as $header) {
    header($header);
}
if ($app['response']['body'] !== null) {
    echo $app['response']['body'];
}
{% endhighlight %}

As you can see, this is essentially a "Hello World" app on steroids, and its structure -- which is completed defined in arrays, is flexible and intuitive.  This simple structure could be used to build both simple and complex apps alike.

At this point, I'd like to answer some of the common questions that people have when they first stumble upon array-oriented programming.

### Q: Isn't this overly verbose?

Can there be such a thing?  Way back in the day, there used to be a programming language called "perl" that was very succinct.  People tried to make simple programs with perl, but they found its succinctness to be far too inflexible for the demands of even the early web.  Fortunately for all of us, PHP did not evolve to emulate perl and instead evolved to emulate Java, and perl has since disappeared entirely.  As a result, PHP has curly braces so that servers do not get confused, and there is now the long-standing tradition of building ultra-architected application architectures regardless of the nature of the final product.  Array-oriented programming caters to that tradition.

### Q: Can we use the short array syntax from PHP 5.4?

Of course you can!  But don't.  You see, there are still some rogue fans of the silly concept of succinct code that have voting rights for the PHP core.  We call these people "perlites" and they recently pushed forth that radically antiquated short array syntax.  The problem is, without the keyword "array" to indicate exactly what you're creating, it is difficult for both the developer and even the interpreter itself to figure out what you're trying to do.  It is best to stick with the more verbose, traditional array() syntax.

### Q: How is this better than object-oriented programming?

The biggest problems with object-oriented programming is clarity and consistency.  What are objects?  Where do they exist?  What are they named?  Who creates them?  These fundamental questions are never completely answered in an object-oriented paradigm.  With array-oriented programming, everything is an array.  It doesn't get much more clear or consistent than that!

So there you have it.  Array-oriented programming is changing the face of modern software development, and it is not too late to get on board.  Its benefits are without question, and I'm confident that once you start developing applications in the paradigm, you will wonder why you ever bothered to write programs any other way.
