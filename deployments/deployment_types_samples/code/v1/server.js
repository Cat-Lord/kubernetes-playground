const http = require('http'),
      os = require('os');

console.log("V1 server starting");

var handler = function(request, response) {
  response.writeHead(200);
  response.end("<h1>v1: The beginning</h1>");
};

var www = http.createServer(handler);
www.listen(8080);
