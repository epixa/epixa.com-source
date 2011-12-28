--- 
layout: post
title: Forget Concatenation; Format your strings!
category: php
excerpt: We'd like to avoid doing it, but as developers of dynamic applications, we are frequently forced to build complex strings on the fly.  If you handle this with concatenation, you are almost assuredly creating strings that are difficult to read without careful scrutiny.  Consequently, it is difficult to determine the intent of the completed string which can cause unexpected results or trigger errors.  The functionality offered by sprintf allows us to visualize the template of the string that we're ultimately trying to create, so it can greatly improve readability and save you some annoying debugging time [...]
date: 2010-09-15 20:16:34 -04:00
legacy_id: http://epixa.com/?p=253
---

Forget Concatenation; Format your strings!
==========================================

I do it, you do it, everyone does it!  We all concatenate.  If you're simply combining a few variables or constants together, concatenation is the way to go.  After all, it is quick and easy, and who can complain about that?  However, concatenation does have two serious drawbacks: any sort of string formatting must be done manually, and it is difficult to visualize the "goal" string when it is sufficiently complex.

Fortunately, the PHP core offers [sprintf()][sprintf]/[printf()][printf] which can greatly improve the readability of your code and even limit the amount of work you need to do to perform common formatting and type casting on your strings.

[sprintf]: http://php.net/sprintf
[printf]: http://php.net/printf

Why is String Formatting so Great?
----------------------------------
This is a pretty silly question, I know.  Let's face it, whether or not you use sprintf, you format strings all the time.  You cast variables to certain types, you format float representations of currency, you put multiple values together, etc.  The key here is, sprintf makes all of that incredibly easy, and it does so while making your code easier to read.

Want to do any of the things I just mentioned?  Piece of cake:

{% highlight php %}
<?php
$money = 29.5;
printf('Approximately $%d.', $money);
// outputs: Approximately $29.
printf('Exactly $%01.2f.', $money);
// outputs: Exactly $29.50.

$total = 1;
printf("%d item%s total.", $total, $total != 1 ? 's' : '');
// outputs: 1 item total.
$total++;
printf("%d item%s total.", $total, $total != 1 ? 's' : '');
// outputs: 2 items total.
{% endhighlight %}

Visualize the Goal
------------------
We'd like to avoid doing it, but as developers of dynamic applications, we are frequently forced to build complex strings on the fly.  If you handle this with concatenation, you are almost assuredly creating strings that are difficult to read without careful scrutiny.  Consequently, it is difficult to determine the intent of the completed string which can cause unexpected results or trigger errors.  The functionality offered by sprintf allows us to visualize the template of the string that we're ultimately trying to create, so it can greatly improve readability and save you some annoying debugging time.

Consider creating a fairly simple, dynamic email link in HTML:

{% highlight php %}
<?php
$email = 'dynamic@email.com';

printf('<a href="mailto:%1$s">%1$s</a>', htmlentities($email));
echo '<a href="mailto:' . htmlentities($email) . '>' 
    . htmlentities($email) . '</a>';
{% endhighlight %}

These are both designed to output the same thing, but since the first one separates the string formatting into two distinct parts: it first sets up the goal string and then escapes the variable input.  This separation makes it very clear what you are trying to accomplish and what has to be done to accomplish it, and it is easier to debug either step as a result.

The concatenation version is harder to read and all of your work is muddied throughout the process.  This makes it more difficult to quickly identify bugs.  Speaking of which, did you notice that the concatenation version is bugged in the example?  If not, look closer (if so, thanks for proof reading my code so thoroughly!).  This type of bug is especially heinous since some browsers may render it perfectly fine.

Now, take a look at a dynamic SQL query where I'll let the results speak for themselves.  There is not a bug (that I'm aware of) in this code, so consider this simply from a readability standpoint:

{% highlight php %}
<?php
$userId = 1;
$limit  = 10;
$offset = 30;

$columns = array(
    'b.id', 'b.title', 'b.date', 'b.content', 'u.name', 'u.email'
);

$where = array(
    $dbAdapter->quoteInto('u.id = ?', $userId),
    'b.date_published is not null'
);

$dbAdapter->query(sprintf(
    'SELECT %s 
        FROM Blog b INNER JOIN User u ON u.id = b.user_id 
        WHERE %s LIMIT %d OFFSET %d',
    implode(', ', $columns), implode(' AND ', $where), $limit, $offset
));

$dbAdapter->query(
    'SELECT ' . implode(', ', $columns) 
        . ' FROM Blog b INNER JOIN User u ON u.id = b.user_id 
            WHERE ' . implode(' AND ', $where) 
        . ' LIMIT ' . (int)$limit . ' OFFSET ' . (int)$offset
);
{% endhighlight %}

Concluding Thoughts
-------------------
This is not a very complex concept; while you can do more with the PHP string formatting functions than what I've shown here, they are not miracle gifts to your programming arsenal that will instantly make you god's gift to the web.  They can, however, make your code easier to read, and that translates to less animosity between you and the next sap that has to maintain your code, and they can even save you some time in identifying some common but frustrating mistakes.

Hint: Use sprintf when you're throwing exceptions.  You may find yourself making clearer messages that also include more useful information for the user:

{% highlight php %}
<?php
throw new InvalidArgumentException(sprintf(
    'Received value of type `%s` but expected value of type `integer`',
    gettype($param)
));
{% endhighlight %}
