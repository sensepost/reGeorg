reGeorg
=========

```                    _____
  _____   ______  __|___  |__  ______  _____  _____   ______
 |     | |   ___||   ___|    ||   ___|/     \|     | |   ___|
 |     \ |   ___||   |  |    ||   ___||     ||     \ |   |  |
 |__|\__\|______||______|  __||______|\_____/|__|\__\|______|
                    |_____|
                    ... every office needs a tool like Georg
```
willem@sensepost.com / [@\_w\_m\_\_]

sam@sensepost.com / [@trowalts]

etienne@sensepost.com / [@kamp_staaldraad]

imbeee@qq.com / [@imbeee]


Version
----

1.1

Dependencies
-----------

reGeorg requires Python 2.7 and the following modules:

* [urllib3] - HTTP library with thread-safe connection pooling, file post, and more.
 

Usage
--------------

```
$ reGeorgSocksProxy.py [-h] [-l] [-p] [-r] -u  [-v]

Socks server for reGeorg HTTP(s) tunneller

optional arguments:
  -h, --help            show this help message and exit
  -l , --listen-on      The default listening address
  -p , --listen-port    The default listening port
  -r , --read-buff      Local read buffer, max data to be sent per Request
  -w , --write-buff     Remote read buffer, max data to be received per Response
  -u , --url            The url containing the tunnel script
  -v , --verbose        Verbose output[INFO|DEBUG]
  --payloads-mode       Select reGeorg request headers payloads mode[header|url]
  --without-check       Start proxy without check if tunnel url accessable
  --custom-headers      Set custom header[{'Cookies': 'JSESSIONID=ABC123;Token=asdfghjkl', 'Authorization': 'Basic YWRtaW46YWRtaW4=', 'Referer': 'trusted.net'}]
```

* **Step 1.**
Upload tunnel.(aspx|ashx|jsp|php) to a webserver (How you do that is up to
you)

* **Step 2.**
Configure you tools to use a socks proxy, use the ip address and port you
specified when
you started the reGeorgSocksProxy.py

** Note, if you tools, such as NMap doesn't support socks proxies, use
[proxychains] (see wiki) 

* **Step 3.** Hack the planet :)


Example
---------

```bash
$ python reGeorgSocksProxy.py -l 127.0.0.1 -p 8080 -u https://upload.sensepost.net:8080/tunnel/tunnel.jsp
$ python reGeorgSocksProxy.py -p 8080 -r 4096 -w 4096 -u http://upload.sensepost.net:8080/tunnel/tunnel.jsp --custom-headers "{'Cookies': 'JSESSIONID=ABC123;Token=asdfghjkl', 'Authorization': 'Basic YWRtaW46YWRtaW4=', 'Referer': 'trusted.net'}"
```

ChangeLog
---------

1.1 (2017-12-16)

* Single session mode (imbeee)
* Custom headers.
* Optional buffer size, the transfer speed many times faster.
* Optional url check.
* Proxy headers payloads can be selected between URL parameters and Request headers.

TODO
---------

* The proxy header need to be obfuscated. (WAF bypass)

License
----

MIT


[@\_w\_m\_\_]:http://twitter.com/_w_m__
[@trowalts]:http://twitter.com/trowalts
[@kamp_staaldraad]:http://twitter.com/kamp_staaldraad
[@imbeee]:https://www.imbeee.com/
[@gorgias]:https://gorgias.me/
[urllib3]:https://pypi.python.org/pypi/urllib3
[proxychains]:http://sourceforge.net/projects/proxychains/
