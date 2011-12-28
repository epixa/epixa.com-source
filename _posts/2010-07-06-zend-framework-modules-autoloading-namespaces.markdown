--- 
layout: post
title: "Zend Framework Modules: Autoloading & Namespaces"
category: php
excerpt: Modules are natively supported in Zend Framework, but their implementation is not conducive to flexible autoloading nor the use of namespaces in PHP 5.3.  There may be a few contributors out there that will defend the current implementation of module autoloading, but throughout the development lifecycle of the current Model-View-Controller implementation in the framework, poor design decisions have made working with modules less flexible and more frustrating [...]
date: 2010-07-06 07:45:19 -04:00
legacy_id: http://epixa.com/?p=231
---

Zend Framework Modules: Autoloading & Namespaces
================================================

Modules are natively supported in Zend Framework, but their implementation is not conducive to flexible autoloading nor the use of namespaces in PHP 5.3.  There may be a few contributors out there that will defend the current implementation of module autoloading, but throughout the development lifecycle of the current Model-View-Controller implementation in the framework, poor design decisions have made working with modules less flexible and more frustrating.

The First Problem
-----------------
The problem stems from the initial decisions about the naming conventions for directories and classes for controllers and views.  The convention that controllers would be stored in a directory called "controllers" and views would be stored in a directory called "views" throws any attempt at dynamic autoloading immediately out the window.  Instead, this single design decision served to ensure that all attempts to autoload consistently-named module-based PHP classes would require some sort of explicit configuration.  As a result, many developers decided to put their classes such as forms, models, and mappers into separate libraries -- not very modular, eh?

The Official Solution: AKA The Second Problem
---------------------------------------------
Enter the current implementation of "resource" autoloading.  This greatly anticipated addition to Zend Framework was to solve our insatiable hunger for module-specific classes (hereto referred to as "resources").  The immediate effect was our modules could finally autoload our most used module resources.  Unfortunately, every single type of resource has to be explicitly defined for each module!  To help make this configuration easier, a "module" autoloader was added to Zend_Application that pre-configures common resources such as models and forms.  But think of that for a second.  An entire class was added to the framework with no other purpose other than pre-configuring options.  If that doesn't scream red-flag, I don't know what does.

Let's Talk Solutions
--------------------
I am extremely opinionated, and I could probably rant for hours about a topic like this, but I digress.  Instead, let's look at a proof of concept that I implemented:

[http://github.com/epixa/Epixa](http://github.com/epixa/Epixa)

The premise is pretty simple: modules should be nothing less than near-independent libraries of code.  When modules are treated like libraries in their own right, they gain all of the flexibility and speed that we get from autoloading library files.  Better yet, the main autoloader in Zend Framework can handle the autoloading all on its own, which means your module resources can be namespaced.

With extensions in that library, you can achieve a directory structure like the following with little to no configuration: 

![Screenshot of Epixa example directory structure](http://epixa.com/files/2010/06/epixa-app-directory-structure.png "Epixa Example App Directory Structure")

What We're Missing
------------------
This is currently to serve only as a proof of concept, so there is still plenty that can be added.  For instance, while I updated the dispatcher so controllers are namspaced like "Blog\Controller\Post", I did not remove the class loading logic from the dispatcher itself.  To separate concerns, the controller class loading *should* be passed off entirely to the autoloader.

The library also still leaves a lot to be desired when it comes to efficient module bootstrapping and plugin loading.  I'll post improvements in both of those regards along with module dependency loading in the near future.

In the meantime, I would love feedback about this approach.  If I can refine it a bit further, I plan to campaign for its inclusion as the standard module setup in Zend Framework 2.
