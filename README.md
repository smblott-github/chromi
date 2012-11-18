chromi
======

Chromi does very little on its own.  It's primarily relevant as the server for
[Chromix](https://github.com/smblott-github/chromix).

Chromi is in two parts:

  1. a simple web-socket server, and
  2. a chrome extension.

The web-socket server is just a simple echo server.  It accepts connections (by
default on `localhost` port `7441`).  Whenever it receives a message from a
client, the server forwards it to all clients (including back to the original sender).

The chrome extension connects to the server.  When it receives a suitable
message, it executes chrome API commands and bounces the responce back to the
server (and hence also to the original client).

The extension expects text messages with four space-sparated fields on a single line:

  1. the literal word `chromi`,
  2. an identifier (which must match the regexp `/\d+/`),
  3. a function identifier (such as `chrome.windows.getAll`), and
  4. a URL encoded, JSON stringified list of arguments for the function.

The extension calls the indicated function with the given argument and responds with a message of the form:

  1. the literal word `Chromi` (not the leading capital "C"),
  2. the identifier provided with the resquest,
  3. the literal word `done`, and
  4. a URL encoded, JSON stringified list of results from the function's invocation.

That's the extent of the documentation for the moment: chromi is a work in progress.

There are dependencies.  These include, but may not be limited to:

  - Node.js
  - Coffeescript (install with `npm`)
  - Optimist (install with `npm`)
  - The `ws` web socket implementation (install with `npm`)

To build chromi, run `cake build` in the project's root folder.  The extension
can then be installed and the server run with an invocation such as `node
script/server.js`.
