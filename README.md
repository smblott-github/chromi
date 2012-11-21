chromi
======

Chromi is a simple Chrome extension.  Chromi does not
include a server or a client, so it does very little on its own.
It's most likely to be of interest as the
server for [Chromix](https://github.com/smblott-github/chromix).

Communication is as follows:

  - Chromix client <--> Chromix server <--> Chromi extension

    Only the Chromi extension is included here.  The client and server are
    available from the [Chromix
    project](https://github.com/smblott-github/chromix).

Who Might Want to Use Chromi?
-----------------------------

...anyone who wants scripted access to [Chrome's extension
API](http://developer.chrome.com/extensions/api_index.html) from outside of
Chrome itself.

For example, with Chromi clients can ask Chrome to load, focus or reload a
tab, remove tabs, or extract Chrome's bookmarks -- all from outside of Chrome
itself.

### Security Warning ...

Chromi opens a TCP socket to a server on `localhost`.
Malicious software with access to that socket may gain unintended access to
Chrome's extension APIs.

### New! (21/11/2012)

The Chromi extension is now available on the [Chrome Web
Store](https://chrome.google.com/webstore/detail/chromi/eeaebnaemaijhbdpnmfbdboenoomadbo).

Details
-------

The Chrome extension connects to the server.  When it receives a
suitablly-formatted message, it executes the requested Chrome API function and
bounces the responce back to the server (and hence also to the original
client).

The extension expects text messages with four space-sparated fields:

  1. the literal word `chromi`,
  2. an identifier (which must match the regexp `/^\d+$/`),
  3. the path to a Chrome Javascript function  (such as `chrome.windows.getAll`), and
  4. a URI encoded, JSON stringified list of arguments.

The extension calls the indicated function with the given arguments and
responds with a message of the form:

  1. the literal word `Chromi` (note the capital "C", this time),
  2. the identifier provided with the original resquest,
  3. the literal word `done` (or `error`, in the event of failure), and
  4. a URI encoded, JSON stringified list of results from the function's invocation.

Chromi is a work in progress.
So that's the extent of the documentation for the moment. Except for the folowing examples, ...

Examples
--------

### Client to Server

Here's an example of an on-the-wire client request:
```
chromi 137294406 chrome.tabs.update %5B86%2C%7B%22selected%22%3Atrue%7D%5D
```
which, when URI decoded, reads:
```
chromi 137294406 chrome.tabs.update [86,{"selected":true}]
```
The client is requesting that Chrome focus tab number `86`.  It may have
learned this tab identifier via an earlier call to
`chrome.windows.getAll`.

Notice that the Chrome API [tab update
method](http://developer.chrome.com/extensions/tabs.html#method-update) accepts
three arguments: `tabId`, `updateProperties` and `callback`.  In this example,
just the first two have been provided.  Chromi itself provides
the callback, and that callback arranges to broadcast the response.

This is the general approach to using Chromi:  the caller must provide *all*
arguments up to *just before* the callback, and Chromi
adds the callback.

### Server to Client

The corresponding response from the extension is:
```
Chromi 137294406 done %5B%7B%22active%22%3Atrue%2C%22favIconUrl%22%3A%22http%3A%2F%2Fwww.met.ie%2Ffavicon.ico%22%2C%22highlighted%22%3Atrue%2C%22id%22%3A86%2C%22incognito%22%3Afalse%2C%22index%22%3A2%2C%22pinned%22%3Afalse%2C%22selected%22%3Atrue%2C%22status%22%3A%22complete%22%2C%22title%22%3A%22Rainfall%20Radar%20-%20Met%20%C3%89ireann%20-%20The%20Irish%20Meteorological%20Service%20Online%22%2C%22url%22%3A%22http%3A%2F%2Fwww.met.ie%2Flatest%2Frainfall_radar-old.asp%22%2C%22windowId%22%3A1%7D%5D

```
which, when URI decoded, is:
```
Chromi 137294406 done [{"active":true,"favIconUrl":"http://www.met.ie/favicon.ico","highlighted":true,"id":86,"incognito":false,"index":2,"pinned":false,"selected":true,"status":"complete","title":"Rainfall Radar - Met Éireann - The Irish Meteorological Service Online","url":"http://www.met.ie/latest/rainfall_radar-old.asp","windowId":1}]
```
Here, the request succeeded and returned a snapshot of the [tab's
state](http://developer.chrome.com/extensions/tabs.html#type-Tab).
This is the data passed to its callback by `chrome.tabs.update` within the
extension.

Dependencies and Installation
-----------------------------

The Chromi extension is available on the [Chrome Web
Store](https://chrome.google.com/webstore/detail/chromi/eeaebnaemaijhbdpnmfbdboenoomadbo).

Alternatively, the extension can be installed as an unpacked extension directly from
the project folder (see "Load unpacked extension..." on Chrome's "Extensions"
page).  It may be necessary to enable "Developer mode" in Chrome.

To build the Chromi extension locally, the
dependencies include, but may not be limited to:

  - [Node.js](http://nodejs.org/)
  
    (Install with your favourite package manager, perhaps something like `sudo apt-get install node`.)
  - [Coffeescript](http://coffeescript.org/)
  
    (Install with something like `npm install coffee-script`.)

To build Chromi, run `cake build` in the project's root folder.  This compiles
the Coffeescript source to Javascript.

`cake` is installed by `npm` as part of the `coffee-script` package.  Depending
on how the install is handled, you may have to search out where `npm` has
installed `cake`.

Notes
-----

If a connection to the server cannot be established or if a connection fails,
then the extension attempts to reconnect once every five seconds.

