# HNReader

HNReader is an iOS news and comment reader app for [Hacker News](http://news.ycombinator.com/).

Data is retrieved directly from the website and the HTML content is parsed using libxml2. The parsing logic is tightly coupled with the page structure. Additionally, webpages can be rendered using [readable](https://github.com/fiam/readable), a small C library that extracts the main content from an HTML document.

## Setup

Setup it easy. Clone the repo locally and install the required dependencies. The [readable](https://github.com/fiam/readable) library is pulled in via a submodule.

	$ git clone https://github.com/andyshep/HNReader.git && cd HNReader
	$ git submodule update --init --recursive

[![entries page](http://i.imgur.com/q7O88LZ.png)](http://i.imgur.com/q7O88LZ.png)
[![comments page](http://i.imgur.com/sMvUolC.png)](http://i.imgur.com/sMvUolC.png)

