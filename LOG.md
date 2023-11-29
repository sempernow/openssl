# OpenSSL

# 2022-01-13

### TLS @ `https://swarm.foo` : multi-node @ hyperv

@ `site.crt` (versus `site.fullchain.crt`); EITHER work fine.

```none
☩ curl -v https://swarm.foo/readiness --connect-timeout 1                                      
*   Trying ::1...                                                                              
* TCP_NODELAY set                                                                              
* connect to ::1 port 443 failed: Connection refused                                           
*   Trying 127.0.0.1...                                                                        
* TCP_NODELAY set                                                                              
* connect to 127.0.0.1 port 443 failed: Connection refused                                     
*   Trying 192.168.1.22...                                                                     
* TCP_NODELAY set                                                                              
* After 495ms connect time, move on!                                                           
* connect to 192.168.1.22 port 443 failed: Connection timed out                                
*   Trying 192.168.1.23...                                                                     
* TCP_NODELAY set                                                                              
* Connected to swarm.foo (192.168.1.23) port 443 (#0)                                          
* ALPN, offering h2                                                                            
* ALPN, offering http/1.1                                                                      
* successfully set certificate verify locations:                                               
*   CAfile: /etc/ssl/certs/ca-certificates.crt                                                 
  CApath: /etc/ssl/certs                                                                       
* TLSv1.3 (OUT), TLS handshake, Client hello (1):                                              
* TLSv1.3 (IN), TLS handshake, Server hello (2):                                               
* TLSv1.2 (IN), TLS handshake, Certificate (11):                                               
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):                                       
* TLSv1.2 (IN), TLS handshake, Server finished (14):                                           
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):                                      
* TLSv1.2 (OUT), TLS change cipher, Client hello (1):                                          
* TLSv1.2 (OUT), TLS handshake, Finished (20):                                                 
* TLSv1.2 (IN), TLS handshake, Finished (20):                                                  
* SSL connection using TLSv1.2 / ECDHE-ECDSA-AES256-GCM-SHA384                                 
* ALPN, server accepted to use h2                                                              
* Server certificate:                                                                          
*  subject: C=US; ST=DE; L=Middletown; O=Sempernow LLC; OU=Sempernow LLC; CN=swarm.foo         
*  start date: Dec  5 16:21:02 2021 GMT                                                        
*  expire date: Dec 25 16:21:02 2023 GMT                                                       
*  subjectAltName: host "swarm.foo" matched cert's "swarm.foo"                                 
*  issuer: C=US; ST=DE; L=Middletown; O=Sempernow LLC; CN=swarm.foo                            
*  SSL certificate verify ok.                                                                  
* Using HTTP2, server supports multi-use                                                       
* Connection state changed (HTTP/2 confirmed)                                                  
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0               
* Using Stream ID: 1 (easy handle 0x7ffff3c01620)                                              
> GET /readiness HTTP/2                                                                        
> Host: swarm.foo                                                                              
> User-Agent: curl/7.58.0                                                                      
> Accept: */*                                                                                  
>                                                                                              
* Connection state changed (MAX_CONCURRENT_STREAMS updated)!                                   
< HTTP/2 200                                                                                   
< server: nginx                                                                                
< date: Thu, 13 Jan 2022 15:14:23 GMT                                                          
< content-type: application/json; charset=UTF-8                                                
< content-length: 26                                                                           
< cache-control: no-store, no-transform                                                        
< content-encoding: identity                                                                   
< x-content-type-options: nosniff                                                              
< strict-transport-security: max-age=63072000                                                  
<                                                                                              
* Connection #0 to host swarm.foo left intact                                                  
{"status":"ok","code":200}                                                                     
```


### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](file:///d:/1%20Data/IT/___.html "@ browser") | [MD](file:///d:/1%20Data/IT/___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

