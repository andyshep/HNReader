HNReader
===

HNReader is an iOS news and comment reader app for [Hacker News](http://news.ycombinator.com/). Developed for personal use, the app serves as an experimental playground for trying out new frameworks and design patterns. The current version uses Reactive Cocoa with an MVC design pattern.

######Network Layer
Networking calls are made using AFNetworking through a category method on [``AFHTTPRequestOperationManager``](https://github.com/andyshep/HNReader/blob/master/HNReader/AFHTTPRequestOperationManager%2BHNReactiveExtension.m) that creates a ``RACSignal`` with an ``AFHTTPRequestOperation`` inside. This provides a simple abstraction for performing ``NSURLRequest``s in a reactive manner.

######HTML Parsing
Data is retrieved directly from the [Hacker News](http://news.ycombinator.com/) website and the HTML content is parsed using [Objective-C-HTML-Parser](https://github.com/zootreeves/Objective-C-HMTL-Parser). The parsing logic is tightly coupled with the page structure. Additionally, webpages can be renderred using [readable](https://github.com/fiam/readable), a small C library that extracts the main content from an HTML document.

######Local Persistence



Screenshots
-------------

[![entries page](http://i.imgur.com/q7O88LZ.png)](http://i.imgur.com/q7O88LZ.png)
[![comments page](http://i.imgur.com/sMvUolC.png)](http://i.imgur.com/sMvUolC.png)

Caveats
-----
Intended for hobbiest use only.