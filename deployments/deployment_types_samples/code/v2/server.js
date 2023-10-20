const http = require('http'),
      os = require('os');

console.log("V2 server starting...");

var handler = function(request, response) {
  response.writeHead(200);
  response.end("<h1>The rise of V2</h1>");
};

var www = http.createServer(handler);
www.listen(8080);
