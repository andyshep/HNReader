HNReader
===

HNReader is an iOS news and comment reader app for [Hacker News](http://news.ycombinator.com/). Developed for personal use, the app serves as an experimental playground for trying out new frameworks and design patterns. The current version uses Reactive Cocoa with an MVC design pattern.

Network requests are made using ``NSURLSession``s that are returned inside a ``RACSignal``. This provides a nice abstraction for executing ``NSURLRequest``s in a reactive manner. 

Data is retrieved directly from the website and the HTML content is parsed using [Objective-C-HTML-Parser](https://github.com/zootreeves/Objective-C-HMTL-Parser). The parsing logic is tightly coupled with the page structure. Additionally, webpages can be rendered using [readable](https://github.com/fiam/readable), a small C library that extracts the main content from an HTML document.

A local cache of entries and comments is maintained using [YapDatabase](https://github.com/yaptv/YapDatabase). Cached items are keyed by entry id or page name. Both are set to expire when the refresh button is tapped or the cache limit is reached.

##Setup

Setup it easy. Clone the repo locally and install the required dependencies. The [readable](https://github.com/fiam/readable) library is pulled in via a submodule while the remaining dependencies are installed via [CocoaPods](http://cocoapods.org).

	$ git clone https://github.com/andyshep/HNReader.git && cd HNReader
	$ git submodule update --init --recursive
	$ pod install

[![entries page](http://i.imgur.com/q7O88LZ.png)](http://i.imgur.com/q7O88LZ.png)
[![comments page](http://i.imgur.com/sMvUolC.png)](http://i.imgur.com/sMvUolC.png)