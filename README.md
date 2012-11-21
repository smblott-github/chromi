Chromi
======

Chromi is a Chrome extension that *facilitates* command-line and scripted
control of Chrome through Chrome's extension
[API](http://developer.chrome.com/extensions/api_index.html).  Chromi does not
include a server or a client, so it does very little on its own.  A server and
client are available in the
[Chromix](https://github.com/smblott-github/chromix) project.

Who Might Want to Use Chromi?
-----------------------------

...anyone who wants command-line or scripted access to Chrome's extension
[API](http://developer.chrome.com/extensions/api_index.html) from outside of
Chrome itself.
For example, Chromi allows clients to ask Chrome to load, focus or reload a
tab, remove tabs, or extract Chrome's bookmarks -- all from outside of Chrome
itself.

Here's an example from [Chromix](https://github.com/smblott-github/chromix):
```
chromix with http://www.bbc.co.uk/news/ reload
chromix with http://www.bbc.co.uk/news/ focus
```
Reload the BBC News tab, and focus it.

Only the Chromi extension is included in this project.  The client and server are
available from the [Chromix](https://github.com/smblott-github/chromix) project.

### Security Warning ...

Chromi opens a TCP socket to a server on `localhost`.  Malicious software with
access to that socket may gain unintended access to Chrome's extension APIs.

### New! (21/11/2012)

The Chromi extension is now available on the [Chrome Web
Store](https://chrome.google.com/webstore/detail/chromi/eeaebnaemaijhbdpnmfbdboenoomadbo).

Details
-------

### Approach

The Chrome security model limits how extensions interact with
the host operating system, and *vice versa*.  This makes it difficult to
control Chrome from the command line or via scripts.

Chromi overcomes these limitations through the use of a web socket.
Specifically, Chromi uses the following architecture:

  - Client `<-->` Server (`ws://localhost:7441`) `<-->` Chromi (within Chrome)  
    (where `<-->` indicates a web socket connection).

The Chromi extension connects to a web socket server on `localhost:7441`.  Clients
connecting to that same socket can then send messages to the extension and
receive responses.

Client's have access to all of the callback-based operations exported by the
Chrome [API](http://developer.chrome.com/extensions/api_index.html).
Event-based callbacks are *not* currently supported.

### Messages

When Chromi receives a suitably-formatted message, it
executes the requested Chrome API function and bounces the response back to the
server (and hence also to the original client).

The extension accepts text messages with four space-separated fields:

  1. the literal word `chromi`,
  2. an identifier (which must match the regexp `/^\d+$/`),
  3. the path to a Chrome JavaScript function  (such as `chrome.windows.getAll`), and
  4. a URI encoded, JSON stringified list of arguments.

The extension calls the indicated function with the given arguments and
responds with a message of the form:

  1. the literal word `Chromi` (note the capital "C", this time),
  2. the identifier provided with the original request,
  3. the literal word `done` (or `error`, in the event of failure), and
  4. a URI encoded, JSON stringified list of results from the function's invocation.

Chromi is a work in progress: so that's the extent of the documentation for the
moment. Except for the following examples, ...

### Examples

#### Client to Server

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

Notice that
[`chrome.tabs.update`](http://developer.chrome.com/extensions/tabs.html#method-update)
accepts three arguments: `tabId`, `updateProperties` and `callback`.  In this
example, just the first two have been provided.  Chromi itself provides the
callback, and that callback arranges to broadcast the response.

This is the general approach to using Chromi:  the caller *must provide all
arguments up to just before the callback*, and Chromi
adds the callback.

#### Server to Client

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
This is the data passed by `chrome.tabs.update` to its callback.

Dependencies and Installation
-----------------------------

The Chromi extension is available on the [Chrome Web
Store](https://chrome.google.com/webstore/detail/chromi/eeaebnaemaijhbdpnmfbdboenoomadbo).

Alternatively, the extension can be
[downloaded](https://github.com/smblott-github/chromi/downloads) and installed
as an unpacked extension directly from the project folder (see "Load unpacked
extension..." on Chrome's "Extensions" page).  It may be necessary to enable
"Developer mode" in Chrome.

The dependencies for building Chromi include, but may not be limited to:

  - [Node.js](http://nodejs.org/)  
    (Install with your favourite package manager, perhaps something like `sudo apt-get install node`.)

  - [CoffeeScript](http://coffeescript.org/)  
    (Install with something like `npm install coffee-script`.)

Run `cake build` in the project's root folder.  This compiles the CoffeeScript
source to JavaScript.

`cake` is installed by `npm` as part of the `coffee-script` package.  Depending
on how the install is handled, you may have to search for where `npm` has
installed `cake`.

Notes
-----

If it cannot connect to the server or if a connection fails, then Chromi
attempts to reconnect once every five seconds.

### TODO:

  1. Allow the TCP port number to be configured via an options page.
  2. Is there a reasonable approach to securing communications?
  3. Support callbacks on Chrome events.
