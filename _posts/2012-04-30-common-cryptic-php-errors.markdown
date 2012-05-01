---
layout: post
title: "Common, Cryptic PHP Errors"
category: php
excerpt: "If you've been programming for awhile, then you've probably experienced your fair share of cryptic error messages.  It's understandable that building in detailed error messages that are clear to even novice developers is not always a high priority for programming languages when there are so many other features to create and issues to address.  The PHP language has decent error messages, but it is by no means an exception to this rule [...]"
date: 2012-04-30 12:00:00 -05:00
---

# Common, Cryptic PHP Errors

If you've been programming for awhile, then you've probably experienced your fair share of cryptic error messages.  It's understandable that building in detailed error messages that are clear to even novice developers is not always a high priority for programming languages when there are so many other features to create and issues to address.  The PHP language has decent error messages, but it is by no means an exception to this rule.

The following three error messages are as cryptic as they are common, but fortunately they are all easy to fix.

## Fatal error: Parse error: syntax error, unexpected T_PAAMAYIM_NEKUDOTAYIM in /path/to/index.php on line 48

Paamayim Nekudotayim is hebrew for "twice colon", and it is the term adopted by Andi Gutmans and Zeev Suraski when they wrote the Zend engine for PHP 3.  The more technical term for this is the [Scope Resolution Operator](http://www.php.net/manual/en/language.oop5.paamayim-nekudotayim.php), and it is used for accessing static properties and methods on classes.  When you see this error, you are probably trying to access a static method or property on a non existent class name.

If you've never experienced this error before, chances are it wouldn't take you too long to hunt down the problem.  Writer daleV from Greek Gumbo created [this](http://www.geekgumbo.com/2011/01/30/paamayim-nekudotayim/) excellent write up detailing this particular bug last year.

## Fatal error: Can't use function return value in write context in /path/to/index.php on line 48

This error is a little more insidious than T_PAAMAYIM_NEKUDOTAYIM since, without experiencing it before, you may not realize what the problem is with a given line of code even if you were staring straight at it.  This issue crops up when you try to pass the returned value from a function directly into either the isset() or empty() functions.  This is easily resolved by storing the returned value in a variable first, but it does seem a little inconsistent, especially for new developers that have no concept of a construct versus a built-in function.

At the time of this writing, there is actually an [RFC](https://wiki.php.net/rfc/empty_isset_exprs) that is in the voting phase for inclusion into the PHP core that addresses this issue for the empty() function.  During the course of discussion about the RFC, it was decided that it was a bad idea to change this behavior for isset() as it is semantically confusing.

## Fatal error: Exception thrown without a stack frame in Unknown on line 0

This is about as bad as error messages could possibly get as it requires you to have detailed knowledge about the technical implementation of the language for it to make any sense whatsoever.  Also, no matter where this error occurs in your application, the error message still says that it happened in file "Unknown" and on line "0".

This error is triggered when any exception is thrown but not caught from within a class destructor (i.e. __destruct()).

When this happens, you do not really have many options other than hunting down the destructors in all of your objects to see which one may fail.  May I suggest: ```grep --color -rn "n __destruct"``` to help hunt down the issue in a linux terminal.

You can save yourself a whole lot of frustration in the future if you keep these three error messages in the back of your mind.