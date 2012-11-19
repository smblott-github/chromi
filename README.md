chromi
======

Chromi is a simple websocket server and a chrome extension.  Chromi does not
include a client, so it does very little on its own.
It's most likely to be of interest as the
server for [Chromix](https://github.com/smblott-github/chromix).

Who Might Want to Use Chromi?
-----------------------------

...anyone who wants scripted access to [chrome's extension
API](http://developer.chrome.com/extensions/api_index.html) from outside of
chrome itself.

For example, chromi can ask chrome to load, focus or reload a tab, remove tabs,
or extract chrome's bookmarks -- all from outside of chrome itself.

### Security Warning ...

The chromi server accepts requests on a TCP socket on `localhost` (by default).
Malicious software with access to that socket may gain unintended access to
chrome's extension APIs.

Details
-------

Chromi consists of two parts:

  1. a simple websocket server, and
  2. an associated chrome extension.

### The WebSocket Server

The websocket server is just a simple echo server.  It accepts connections
on `localhost` port `7441`.  It then forwards each message it receives to
*all* clients (including to the original sender).

### The Chrome Extension

The chrome extension connects to the server.  When it receives a
suitablly-formatted message, it executes the requested chrome API function and
bounces the responce back to the server (and hence also to the original
client).

The extension expects text messages with four space-sparated fields on a single line:

  1. the literal word `chromi`,
  2. an identifier (which must match the regexp `/\d+/`),
  3. the path to a chrome Javascript function  (such as `chrome.windows.getAll`), and
  4. a URL encoded, JSON stringified list of arguments.

The extension calls the indicated function with the given arguments and
responds with a message of the form:

  1. the literal word `Chromi` (note the capital "C"),
  2. the identifier provided with the resquest,
  3. the literal word `done` (or `error`, in the event of failure), and
  4. a URL encoded, JSON stringified list of results from the function's invocation.

Chromi is a work in progress.
So that's the extent of the documentation for the moment. Except for the folowing examples, ...

Examples
--------

### Client to Server

Here's an example of an on-the-wire client request:
```
chromi 137294406 chrome.tabs.update %5B86%2C%7B%22selected%22%3Atrue%7D%5D
```
which, when URL decoded, reads:
```
chromi 137294406 chrome.tabs.update [86,{"selected":true}]
```
The client is requesting that chrome focus tab number `86`.  It may have
learned this tab identifier via an earlier call to
`chrome.windows.getAll`.

Notice that the chrome API [tab update
method](http://developer.chrome.com/extensions/tabs.html#method-update) accepts
three arguments: `tabId`, `updateProperties` and `callback`.  In this example,
just the first two have been provided.  Chromi itself provides
the callback, and that callback arranges to broadcast the response.

This is the general approach to using chromi:  the caller must provide *all*
arguments up to *just before* the callback, and chromi
adds the callback.

### Server to Client

The corresponding response from the extension is:
```
Chromi 137294406 done %5B%7B%22active%22%3Atrue%2C%22favIconUrl%22%3A%22http%3A%2F%2Fwww.met.ie%2Ffavicon.ico%22%2C%22highlighted%22%3Atrue%2C%22id%22%3A86%2C%22incognito%22%3Afalse%2C%22index%22%3A2%2C%22pinned%22%3Afalse%2C%22selected%22%3Atrue%2C%22status%22%3A%22complete%22%2C%22title%22%3A%22Rainfall%20Radar%20-%20Met%20%C3%89ireann%20-%20The%20Irish%20Meteorological%20Service%20Online%22%2C%22url%22%3A%22http%3A%2F%2Fwww.met.ie%2Flatest%2Frainfall_radar-old.asp%22%2C%22windowId%22%3A1%7D%5D

```
which, when URL decoded, is:
```
Chromi 137294406 done [{"active":true,"favIconUrl":"http://www.met.ie/favicon.ico","highlighted":true,"id":86,"incognito":false,"index":2,"pinned":false,"selected":true,"status":"complete","title":"Rainfall Radar - Met Éireann - The Irish Meteorological Service Online","url":"http://www.met.ie/latest/rainfall_radar-old.asp","windowId":1}]
```
Here, the request succeeded and returned a snapshot of the [tab's
state](http://developer.chrome.com/extensions/tabs.html#type-Tab).
This is the data passed to its callback by `chrome.tabs.update` within the
extension.

Dependencies
------------

Dependencies include, but may not be limited to:

  - [Node.js](http://nodejs.org/) (install with your favourite package manager)
  - [Coffeescript](http://coffeescript.org/) (install with `npm`)
  - [Optimist](https://github.com/substack/node-optimist) (install with `npm`)
  - The [ws](http://einaros.github.com/ws/) websocket implementation (install with `npm`)

Installation
------------

To build chromi, run `cake build` in the project's root folder.  This compiles
the Coffeescript source to Javascript.

### Extension Installation

The extension can be installed as an unpacked extension directly from
the project folder (see "Load unpacked extension..." on chrome's "Extensions"
page).

If a connection to the server cannot be established or if a connection fails,
then the extension attempts to reconnect once every five seconds.

### Server Installation

The server can be run with an invocation such as:
```
node script/server.js
```
The extension broadcasts a heartbeat every five seconds.  If everything's
working correctly, then these heartbeats (and all other messages) appear on the
server's standard output (URL decoded).

The server might beneficially be run under the control of a supervisor daemon
such as [daemontools](http://cr.yp.to/daemontools.html) or
[supervisord](http://supervisord.org/).
