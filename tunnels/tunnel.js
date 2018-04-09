var http = require('http');
var net = require('net');
var dataBuff = [];
var sessions = [];

function attachOutboundListener(outboundTCP)
{
        outboundTCP.on('data', function(data) {
        for(var key in sessions)
        {
            if(sessions[key]=outboundTCP)
            {
             dataBuff[key]=data;
            }
        }
        });
}

function createOutboundTCP(res,req)
{
    var reqCookie=req.headers['cookie'];
    var HOST = req.headers['x-target'];
    var PORT = req.headers['x-port'];

    if(reqCookie==null)
    {
            var tcpConn = new net.Socket();

            tcpConn.connect(PORT,HOST);

            tcpConn.on( 'connect', function() {
                        var cookie='Ur'+Math.random();
                        sessions[cookie]=tcpConn;
                        attachOutboundListener(tcpConn);
                        res.writeHead(200,{'Set-Cookie':cookie,'X-STATUS':'OK'});
                        res.end();
            });

            tcpConn.on('error', function(error){
               console.log("Error creating new Outbound: "+error.message);
               res.writeHead(200,{'X-STATUS':'FAIL','X-ERROR':error.message});
               res.end();
            });
    }
    else if(reqCookie!=null&&sessions[reqCookie]==null)
    {
            var tcpConn = new net.Socket();
            tcpConn.connect(PORT,HOST);

            tcpConn.on( 'connect', function() {
                      sessions[reqCookie]=tcpConn;
                      attachOutboundListener(tcpConn);
                      res.writeHead(200,{'X-STATUS':'OK'});
                      res.end();
            });

            tcpConn.on('error', function(error){
                      console.log("Error creating new Outbound: "+error.message);
                      res.writeHead(200,{'X-STATUS':'FAIL','X-ERROR':error.message});
                      res.end();
            });
    }
    else
    {
        res.writeHead(200,{'X-STATUS':'OK'});
        res.end();
    }
}

function readOutboundTCP(res,req)
{
    var reqCookie=req.headers['cookie'];

    if(reqCookie!=null)
    {
        var currData=dataBuff[reqCookie];
        dataBuff[reqCookie]=null;

        if(currData!=null)
        {
                res.writeHead(200,{'X-STATUS':'OK'});
                res.write(currData);
                res.end();
        }
        else
        {
                console.log('NO DATA IN BUFFER TO READ');
                res.writeHead(200,{'X-STATUS':'OK'});
                res.end();
        }
    }
    else
    {
        console.log('No cookie to read data');
        res.writeHead(200,{'X-STATUS':'FAIL','X-ERROR':'NO COOKIE'});
        res.end();
    }

}

function disconnectOutboundTCP(res,req,error)
{

    var tcpConn=sessions[req.headers['cookie']];

    if(tcpConn!=null)
    {
        tcpConn.destroy();
        tcpConn=null;
        sessions[req.headers['cookie']]=null;
        dataBuff[req.headers['cookie']]=null;
    }

    if(error!=null)
    {
        res.writeHead(200,{'X-STATUS':'FAIL','X-ERROR':error.message,'Set-Cookie':'; expires=Thu, 01 Jan 1970 00:00:00 GMT'});
        res.end();
     }
     else
     {
     res.writeHead(200,{'Set-Cookie':'; expires=Thu, 01 Jan 1970 00:00:00 GMT','X-STATUS':'OK'});
     res.end();
     }

}

function forwardData(req,res)
{
  var forwardData;

      req.on('data', function (chunk) {
          forwardData=chunk;
        });

      req.on('end', function (){
          if(forwardData!=null)
          {
                  var tcpSocket=sessions[req.headers['cookie']];

                  if(tcpSocket!=null)
                  {
                  tcpSocket.write(forwardData);
                  res.writeHead(200,{'X-STATUS':'OK'});
                  res.end();
                  }
                  else
                  {
                  console.log('No Cookie session to forward');
                  res.writeHead(200,{'X-STATUS':'FAIL','X-ERROR':'NO COOKIE'});
                  res.end();
                  }
          }
          else
          {
                  console.log('No data in FORWARD');
                  res.writeHead(200,{'X-STATUS':'OK'});
                  res.end();
          }

        });
}

var server=http.createServer(function (req, res) {

//   for(var item in req.headers) {
//       console.log('REQ: '+item + ": " + req.headers[item]);
//     }

    var cmd=req.headers['x-cmd'];

    if(cmd!=null)
    {
        if(cmd=='CONNECT')
        {
         console.log('CONNECT')
            try
            {
                createOutboundTCP(res,req);
            }
            catch(error)
            {
                disconnectOutboundTCP(res,req,error);
            }
        }

        else if(cmd=='DISCONNECT')
        {
         console.log('DISCONNECT')
                try
                {
                    disconnectOutboundTCP(res,req,null);
                }
                catch(error)
                {
                    disconnectOutboundTCP(res,req,error);
                }
        }

        else if(cmd=='READ')
        {
        console.log('READ')
                    try
                    {
                       readOutboundTCP(res,req);
                    }
                    catch(error)
                    {
                         disconnectOutboundTCP(res,req,error);
                    }
        }

        else if(cmd=='FORWARD')
        {
                    console.log('FORWARD');
                    try
                    {
                       forwardData(req,res);
                    }
                    catch(error)
                    {
                        disconnectOutboundTCP(res,req,error);
                    }
        }
        else
        {
        res.write("Georg says, 'All seems fine'");
        res.end();
        }
    }

    else
    {
    res.write("Georg says, 'All seems fine'");
    res.end();
    }

});

server.listen(65000, '127.0.0.1');
