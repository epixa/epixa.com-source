--- 
layout: post
title: How PHP is Broken and How It Can Be Fixed
category: php
excerpt: PHP's development process has been broken for a long time, and the failures of that process have swelled since the first ripples began to appear many years ago.  The process didn't necessarily take a downward turn at any point; rather, it seems there was never really sufficient or sustainable workflow from the start.  This is no surprise given the very fluid history of PHP though, and the lack of any sustainable processes may have even been one of the key things that allowed PHP to evolve so quickly into one of the most used programming languages in the world.  But that early success doesn't make the PHP development process any less broken. [...]
date: 2011-08-31 11:49:05 -04:00
legacy_id: http://epixa.com/?p=386
---

How PHP is Broken and How It Can Be Fixed
=========================================

**Edit (Nov 14 2011 6:03pm)** The follow-up article is posted [here][followup].

[followup]: http://epixa.com/2011/11/follow-up-how-php-is-broken-and-how-it-can-be-fixed.html

**Edit (Aug 31 2011 8:05pm):** When I started writing this article, my intentions were to criticize the PHP core developers for what I consider to be a severely broken process.  I do want to make that clear.  As a member of the community and a long-time PHP programmer, I find it indescribably irritating that a failure as significant as the release of PHP 5.3.7 could happen without the dev team at least backing up the release of PHP 5.3.8 with an analysis of exactly what happened and exactly what measures were being considered so that it never happened again.  The problem here is not that a human made an error, the problem is that there were no measures in place to stop that error from happening, and so far there hasn't been (or I haven't seen) an official explanation of what measures will be put in place.

My irritation aside, this blog article does not do a good job identifying exactly what part of the process is broken, and it does an even worse job presenting practical solutions.  The tone I set from the start of the article is more that of an offended user than someone interested in finding solutions, and it is certainly not inline with my original intentions.  The core devs are no doubt responsible for the process in which they work, but they are also the group of people that will ultimately fix this problem.

I will be writing a follow-up to this article in the coming days that will hopefully address the concerns I have about PHP's development process without so much visceral rhetoric.  Blog articles are a great way to present ideas to the public, but they are not a means to really enact change, so if I think my ideas can make a difference for the better, I will bring them to the PHP internals mailing list as well.

**********

PHP's development process has been broken for a long time, and the failures of that process have swelled since the first ripples began to appear many years ago.  The process didn't necessarily take a downward turn at any point; rather, it seems there was never really a sufficient or sustainable workflow from the start.  This is no surprise given the very fluid history of PHP though, and the lack of any sustainable processes may have even been one of the key things that allowed PHP to evolve so quickly into one of the most used programming languages in the world.  But that early success doesn't make the PHP development process any less broken.

Before I continue, I want to be perfectly clear: There are many reasons that people bring up for disliking PHP, and I will not be entertaining most of them here.  If you do not like PHP because of things such as an inconsistent API, seemingly half-hearted additions (e.g. object model or namespace support), or any of the other language-specific beefs that spring up whenever someone leaps on their e-soapbox, please move along.  This isn't the post for you.  All things considered, I like PHP, and I think it is the best option for developing most of the applications that we see on the web today.


How PHP is Broken
-----------------
The serious problems -- the ones that actually have long-term consequences, stem from the development process.

Through most of PHP's 16 year lifespan, it had a completely arbitrary release process.  When core devs felt like they wanted to push a release, they got together, patched up some of the code that had been contributed for the many weeks, months, or years since the previous release, and tossed it out into the wild.  The consequences of this still linger throughout the community (and the entire web) today: without any clear release planning, it was more efficient for organizations to leave their PHP versions un-upgraded than it was to incrementally upgrade their versions in a timely manner.

In addition to no sensible release cycle, the way new features were discussed, approved, or rejected was largely informal, difficult to follow, and without any sufficient time constraints.  It was hard for anyone that didn't follow the mailing list and wiki word for word, every day to have much of any idea about what was going on.

PHP's test coverage is not good.  To make matters worse, passing the existing unit tests is **not a requirement for acceptance** in the core.  Why even write the unit tests if someone can simply choose to ignore them when merging in their code?  This has to be the type of thing that [Sebastian Bergmann][bergmann] has nightmares about.

[bergmann]: http://sebastian-bergmann.de

Don't worry though, just because it is acceptable to commit code that breaks the unit tests doesn't mean that this will actually affect the stability of the releases, right?  I mean, the **stable** releases of PHP at least pass the tests that they do have, right? **Wrong**.  Surely you've all heard about the fiasco that was the PHP 5.3.7 release, but just in case you need a quick refresher:

Eleven days ago, PHP 5.3.7 was [released][537-released] as stable.  One day **prior** to the release, a major bug was [reported][bug-report] that identified an issue where using crypt() with md5 hashes was broken so badly that it was completely unusable across all platforms.  Four days after the stable release, PHP.net finally got around to officially [announcing][bug-announcement] the problem and a day after that they released PHP 5.3.8 with a fix.  To their credit, many of the core devs did get the [word][word-1] [out][word-2] about this issue very quickly, but why it took four days to officially acknowledge the problem is completely beyond me.

[537-released]: http://www.php.net/archive/2011.php#id2011-08-18-1
[bug-report]: https://bugs.php.net/bug.php?id=55439
[bug-announcement]: http://www.php.net/archive/2011.php#id2011-08-22-1
[word-1]: https://plus.google.com/113641248237520845183/posts/g68d9RvRA1i
[word-2]: https://plus.google.com/104059770182664001692/posts/fYqq8HGHF8h

The delay in an official acknowledgement of this issue is certainly disturbing, but here's the kicker: Even at only 70% code coverage, this bug **was** identified by the unit tests.  The tests that were in place to make sure that bugs like this couldn't happen did their jobs -- they failed when they were suppose to fail.  Without any automatic testing constraints in place for packaging releases, those failures went unnoticed, and a "stable" release of PHP with an application-breaking bug was released to the masses.  For this to happen, one of two things had to occur: someone released a stable version without running tests on newly added code, or, more likely, someone didn't notice that there was a really important test failing because **PHP 5.3 has [192 failing unit tests][failed-tests]**!  What on earth is the point of writing unit tests when you consider it OK that some of the tests fail?  The acceptance of these failures is perhaps the most backward-thinking decision that I have ever seen the PHP dev team make.

[failed-tests]: http://gcov.php.net/viewer.php?version=PHP_5_3

How This Can Be Fixed
---------------------
PHP has made huge progress in recent months in getting its development process into an acceptable state.  There is finally a detailed [release process][release-process] in place, so we know when to expect new code.  There is finally a simple and visible [voting process][voting-process] on new feature proposals, so we know what to expect in those upcoming releases.  If the release of 5.3.7 is one of the worst blunders by the PHP dev team ever, then I'd say the addition of these two processes into the overall workflow is perhaps the single greatest decision they have ever made.  Only in time will we be able to see what affect these two additions will have, but already the community is seeing clearer communications and expectations when dealing with proposals and releases.

[release-process]: https://wiki.php.net/rfc/releaseprocess
[voting-process]: https://wiki.php.net/rfc/voting

Stop breaking tests.  Stop it.  Just, stop.  The argument that is immediately brought up whenever someone like me talks about an issue like this is along the lines of "nothing is stopping you from contributing", but that isn't at all relevant here.  Perhaps this argument would carry some weight if you were just considering the mountain of test failures that exist from the past, but that isn't all we're considering.  PHP 5.4 has 26 **more** failed unit tests than PHP 5.3, and PHP HEAD has more still.  Stop accepting code that isn't unit tested or that breaks existing tests.

Fix the broken tests.  I know I just said that maybe you could argue for more contributors in this case, but really that is only one side of the coin.  As a PHP user, it is **not** my responsibility to contribute to PHP.  That's not how open source works, and it never will be how open source works.  But as a user of the software, I **can** be upset when it **doesn't work**.  I can be even more upset when it doesn't work due almost entirely to human negligence.

As core developers, you **do** have a responsibility to personally write good code and to, as a group, manage the project in a responsible manner.  If you do both of these things -- if you do things like writing well-tested code and don't accept bush league crap like untested code (or worse, code that actually breaks tests), then I will be the first one to step to your defense whenever people get on your back.


More Contributors is Not the Solution
-------------------------------------
Throwing new contributors at the project will not fix these problems.  If you want to expand the test coverage, improve the documentation, or do anything else that makes PHP better, then new contributors are the way to go.  However, falling back on cavalier attitudes like the ones behind the statement "nothing is stopping you from contributing" is both insulting and counter-productive.  It does absolutely nothing but decrease peoples' desire to contribute even more.  As core developers, fixing the mistakes in the core development is your responsibility.  Just because you are volunteering your time doesn't make this any less your responsibility.  Volunteering is the act of taking on responsibilities at no cost, and that is something you chose to do.  So, unless you're throwing in the towel and walking away from the project, don't insult the community by trying to offload your responsibilities (and failures) on us.

Also, stop it with stupid reactions like [this][stupid-reaction] (Sorry to single you out, Pierre. You are certainly not the only one with this attitude).  If you are a core developer that helps to write and manage a project that powers websites and applications for billions of combined users, you don't get the luxury of demanding that people remain silent when your team makes an absolutely egregious mistake like the PHP 5.3.7 release just because those people didn't help you identify a mistake that your own processes **should** have identified.  Next time we moan about features taking too much time to develop, feel free to play the "contribute or stfu" card.

[stupid-reaction]: http://twitter.com/PierreJoye/status/105690441105682432 "Tweet says: Do not blame anyone if you did not run tests and report issues using RCs. Do not."