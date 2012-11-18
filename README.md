chromi
======

Chromi does very little on its own.  It's more likely to be of interest as the
server for [Chromix](https://github.com/smblott-github/chromix).

Chromi consists of two parts:

  1. a simple websocket server, and
  2. an associated chrome extension.

So, chromi is a chrome extension which connects to a websocket serever,
thereby giving access to chrome's extension API from outside of chrome itself.
It can be used, for example, to ask chrome to load or focus or reload a page,
or extract chrome's bookmarks or history.

### Warning

chromi accepts requests on a TCP socket (by default) on `localhost`.
Malicious software with access to that socket may gain unwanted access to
chrome .

The WebSocket Server
--------------------

The websocket server is just a simple echo server.  It accepts connections, by
default on `localhost` port `7441`.  It then forwards each message it receives to
all clients (including to the original sender).

The Chrome Extension
--------------------

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
  3. the literal word `done`, and
  4. a URL encoded, JSON stringified list of results from the function's invocation.

That's the extent of the documentation for the moment: chromi is a work in progress.

### Example: Client to Server

Here's an example of an on-the-wire client request:
```
chromi 137294406 chrome.tabs.update %5B86%2C%7B%22selected%22%3Atrue%7D%5D
```
which, when URL decoded, reads:
```
chromi 137294406 chrome.tabs.update [86,{"selected":true}]
```
The client is requesting that chrome focus tab number `86`.

### Example: Server to Client

The corresponding response from the extension is:
```
Chromi 137294406 done %5B%7B%22active%22%3Atrue%2C%22favIconUrl%22%3A%22http%3A%2F%2Fwww.met.ie%2Ffavicon.ico%22%2C%22highlighted%22%3Atrue%2C%22id%22%3A86%2C%22incognito%22%3Afalse%2C%22index%22%3A2%2C%22pinned%22%3Afalse%2C%22selected%22%3Atrue%2C%22status%22%3A%22complete%22%2C%22title%22%3A%22Rainfall%20Radar%20-%20Met%20%C3%89ireann%20-%20The%20Irish%20Meteorological%20Service%20Online%22%2C%22url%22%3A%22http%3A%2F%2Fwww.met.ie%2Flatest%2Frainfall_radar-old.asp%22%2C%22windowId%22%3A1%7D%5D

```
which, when URL decoded, is:
```
Chromi 137294406 done [{"active":true,"favIconUrl":"http://www.met.ie/favicon.ico","highlighted":true,"id":86,"incognito":false,"index":2,"pinned":false,"selected":true,"status":"complete","title":"Rainfall Radar - Met Éireann - The Irish Meteorological Service Online","url":"http://www.met.ie/latest/rainfall_radar-old.asp","windowId":1}]
```
This is the data passed to the callback from `chrome.tabs.update` within the
extension.  In this example, it's a snapshot of the tab's status.

Dependencies and Installation
-----------------------------

There are dependencies.  These include, but may not be limited to:

  - Node.js
  - Coffeescript (install with `npm`)
  - Optimist (install with `npm`)
  - The `ws` websocket implementation (install with `npm`)

To build chromi, run `cake build` in the project's root folder.  The extension
can then be installed and the server run with an invocation such as `node
script/server.js`.

The server might beneficially be run under the supervision of
[daemontools](http://cr.yp.to/daemontools.html),
[supervisord](http://supervisord.org/) or the like.
