--- 
layout: post
title: PHP Integration with Salesforce CRM
category: php
excerpt: "If your primary clientele is small to medium business owners, as I imagine is the case for most professional developers these days, chances are you have developed custom applications that interact with Salesforce CRM. For those of you that have not had the delight of integrating with Salesforce, let\xE2\x80\x99s walk through the most common integration techniques. [...]"
date: 2010-05-18 22:18:28 -04:00
legacy_id: http://epixa.com/?p=156
---

PHP Integration with Salesforce CRM
===================================

If your primary clientele is small to medium business owners, as I imagine is the case for most professional developers these days, chances are you have developed custom applications that interact with Salesforce CRM.  For those of you that have not had the *delight* of integrating with Salesforce, let's walk through the most common integration techniques.

Integrating with Salesforce CRM begins with the Force.com Web Services API.  The API is SOAP based, so you can use PHP's built in soap extension to make calls to the service, but in this tutorial I'll be using the [PHP Toolkit][php-toolkit] provided by Salesforce; you still need to have the php soap extension installed, but the toolkit provides convenient utility methods for all of the available api calls.

[php-toolkit]: http://wiki.developerforce.com/index.php/PHP_Toolkit

Generate your WSDL
------------------
The first thing you'll need to do to access your salesforce via the api is generate a WSDL.  The soap client requires the WSDL in order to, among other things, know what calls it can make to the server.

You have a few options when it comes to generating WSDLs in salesforce; I prefer to use the strongly typed Enterprise WSDL whenever possible.  Enter your salesforce 'setup' section, traverse to Develop > API, and click the "Generate Enterprise WSDL" link (see screenshot below).  On the following step, just leave all the versions at the defaults and click the "Generate" button.  Save the XML that is generated into a new file in your application.

![Screenshot of salesforce setup for generating a wsdl](https://s3.amazonaws.com/epixa.com/images/2010-05-18-php-integration-with-salesforce-crm/salesforce-generate-wsdl.png "Salesforce: Generate WSDL")

Get your Security Token
-----------------------
To access the soap service, you will need to provide your username, password, and the security token that is generated for your account.  The security token is a random 25 character string of uppercase and lowercase letters and numbers.  If you are not sure what your security token is, you can generate a new one through the salesforce 'setup' page (see screenshot below).  While you can reset your security token at any time, take heed of the notices that pepper the security-token section of the salesforce setup: if you change your security token, all existing api applications that rely on the token will break unless they are updated with the new token.

![Screenshot of salesforce setup for resetting login security token](https://s3.amazonaws.com/epixa.com/images/2010-05-18-php-integration-with-salesforce-crm/salesforce-reset-security-token.png "Salesforce: Reset Security Token")

Get your Code On
----------------
Now that we have the boring salesforce groundwork out of the way, let's write some code!  First up, get connected:

{% highlight php %}
<?php

$wsdl  = 'enterprise-wsdl.xml';
$user  = 'example@epixa.com';
$pass  = 'supersecure';
$token = 'fAjfS4FkxLsoqPxmsZujj0Szr';

$client = new SforceEnterpriseClient();
$client->createConnection($wsdl);
$client->login($user, $pass . $token);
{% endhighlight %}

The five core method calls that you *must* know are upsert, retrieve, getUpdated, delete, getDeleted.  There are [many more][api-methods], but knowing these powerful five is sufficient to do a large number of synchronization scripts.

[api-methods]: http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_list.htm

SforceEnterpriseClient::upsert()
--------------------------------
While the Salesforce API does offer create() and update() methods, you will probably find yourself using this nifty function to accomplish either task: [upsert()][upsert] will attempt to insert a new record, and if an existing record that matches the field you specify already exists, it will update that record instead.  For those familiar with MySQL, this is basically the equivalent of INSERT ON DUPLICATE KEY UPDATE.

[upsert]: http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_upsert.htm

{% highlight php %}
<?php

$first = new stdClass();
$first->Name = 'First Epixa Widget';
$first->Description = 'This Epixa Widget is the best product of all time!';

$client->upsert('Name', array($first), 'Product2');
// result: a new product is created in salesforce

$second = new stdClass();
$second->Name = 'Second Epixa Widget';
$second->Description = 'No, THIS Widget is the best product of all time!';
$client->upsert('Name', array($second), 'Product2');
// result: a new product is created in salesforce

$clonedFirst = clone $first;
$clonedFirst->Description = 'FINE, Second Widget.  You can be the best product.';
$client->upsert('Name', array($clonedFirst), 'Product2');
// result: the first object's description is updated in salesforce
{% endhighlight %}

SforceEnterpriseClient::retrieve()
----------------------------------
The core method [retrieve()][retrieve] allows you to query for one or more of a specified Salesforce object given a set of unique Ids:

[retrieve]: http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_retrieve.htm

{% highlight php %}
<?php

$ids = array('01tA0000000YU4D', '01tA0000000YU48');

$results = $client->retrieve('Id, Name, Description', 'Product2', $ids);
print_r($results);
// results:
// Array
// (
//     [0] => stdClass Object
//         (
//             [Id] => 01tA0000000YU48IAG
//             [Description] => FINE, Second Widget.  You can be the best product.
//             [Name] => First Epixa Widget
//         )
//     [1] => stdClass Object
//         (
//             [Id] => 01tA0000000YU4DIAW
//             [Description] => No, THIS Widget is the best product of all time!
//             [Name] => Second Epixa Widget
//         )
// )
{% endhighlight %}

SforceEnterpriseClient::getUpdated()
------------------------------------
Whenever you are polling for data from Salesforce, [getUpdated()][getupdated] is probably the method you're going to use.  This will return an object that contains an array of all the unique Ids of objects that match the supplied type that were updated between the timestamps you pass it.  In addition to the array of Ids, the returned object also contains a timestamp in DATE_ATOM format of the last date covered in your getUpdated call that you can store and use for the start date in your next call to getUpdated().  Couple this with a call to retrieve(), and you can easily query for all objects updated since the last time your script ran.

[getupdated]: http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_getupdated.htm

{% highlight php %}
<?php

$results = $client->getUpdated('Product2', strtotime('-7 days'), time());
print_r($results);
// stdClass Object
// (
//     [ids] => Array
//         (
//             [0] => 01tA0000000YU48IAG
//             [1] => 01tA0000000YU4DIAW
//         )
//     [latestDateCovered] => 2010-05-19T00:29:00.000Z
// )
{% endhighlight %}

SforceEnterpriseClient::delete()
--------------------------------
This does not really require any explanation; however, it is worth noting that objects deleted through the [delete()][delete] method are only logically deleted.  This will simply set the IsDeleted flag to true.

[delete]: http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_delete.htm

{% highlight php %}
<?php

$client->delete(array('01tA0000000YU4D', '01tA0000000YU48'));
// result: Two products with the passed Ids are marked as deleted in salesforce
{% endhighlight %}

SforceEnterpriseClient::getDeleted()
------------------------------------
The method [getDeleted()][getdeleted] is very similar to getUpdated() -- it takes exactly the same parameters, but it returns a slightly different object.  The returned object still has the latestDateCovered property, but it also has an earliestDateAvailable property which is a DATE_ATOM formatted timestamp of the last physically deleted object.  Rather than having an array of Ids, the object returned by getDeleted() has an array of objects each with the Id of the deleted object and the timestamp of when that object was actually deleted.

[getdeleted]: http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_getdeleted.htm

{% highlight php %}
<?php

$results = $client->getDeleted('Product2', strtotime('-7 days'), time());
print_r($results);
// stdClass Object
// (
//     [deletedRecords] => Array
//         (
//             [0] => stdClass Object
//                 (
//                     [deletedDate] => 2010-05-19T02:38:31.000Z
//                     [id] => 01tA0000000YU48IAG
//                 )
//             [1] => stdClass Object
//                 (
//                     [deletedDate] => 2010-05-19T02:38:31.000Z
//                     [id] => 01tA0000000YU4DIAW
//                 )
//         )
//     [earliestDateAvailable] => 2010-03-12T01:13:00.000Z
//     [latestDateCovered] => 2010-05-19T00:29:00.000Z
// )
{% endhighlight %}

Hold up, there are some 'gotchas'
---------------------------------

1. Calls to retrieve() do not always return an array of objects!  If only one result is returned, only that object will be returned.  I cannot begin to imagine who made this bonehead-decision, but it can be frustrating if you're not expecting it.
2. The PHP Toolkit handles some errors by throwing exceptions.  This is immensely convenient.  However, not all errors are thrown!  For methods such as create(), make sure you check the returned value for the property 'errors'.  In addition to signifying that an error has occurred, the 'errors' object contains information that can be useful in debugging the issue.

Integrating with Salesforce can be a frustrating experience, but it is hard to avoid if you work with any small to medium companies that take their CRM solutions seriously.  There are many more possibilities beyond what I outlined here, so I recommend that you familiarize yourself with the API documentation that I linked to throughout this article before beginning any Salesforce integration project.
