---
layout: post
title: "Talk: Building Cloud-Ready Apps"
category: talks
excerpt: This is a talk that I recorded for the Singapore PHP User Group about building apps that can scale horizontally in the cloud.  Among the suggestions are to not write to the file system, use an external database, and keep your repo lean.  [...]
date: 2012-04-02 12:00:00 -05:00
---

Talk: Building Cloud-Ready Apps
===============================

In March 2012, the Singapore PHP User Group was running a lab entitled "PHP In the Cloud".  I put this talk together for them on relatively short notice, but overall I think it turned out pretty well.

In the talk, I mention four things that you can do to help ensure that your app can scale horizontally in the cloud:

1. Store your file uploads on an external file storage service such as Amazon S3.
2. Do not keep your database on the localhost.
3. Use an external memcache server or service for PHP session storage.
4. Keep your VCS repo lean.

<iframe src="http://player.vimeo.com/video/38895356" width="600" height="375" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>
