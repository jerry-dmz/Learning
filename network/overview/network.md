先对整个网络及其实际工程业务场景有一个大概的了解，最好能够结合到实际的工作来理解

从应该广发的web协议开始，至少知道整个协议的大体概况

**网络协议到底是什么**

**网络协议到底学一些什么**

​	通读网络协议，了解应用层协议的时候，最好能结合web服务器实现（http），了解不同网络协议对应的工程实践

​	了解网络完全方面的知识（kali 操作系统，各种网络统计分析工具，各种漏洞原理的了解）

​	对各个设备层的网络有一个大致的了解，能够通过自己的实践对网络环境做判断

**网络协议到底有一些什么帮助**

**步骤:**从最广泛的http协议开始，了解详细的工程场景应用规范，构建整个网络体系的知识图谱构建

# 网络协议初解

#### 1.http协议的定义：

a **stateless** application-level **request-response** protocol that uses **extensible semantics** and **self-descriptive** message payloads for flexible

interaction with network-based **hypertext information** systems

**http协议发展轨迹**：

* **HTTP/0.9**

  时间：1991

  背景：学术交流

  需求：传输体积很小的html文件

  特点：只有一个请求行、没有返回头、返回内容ASCll码传输

* **HTTP/1.0**

  时间：1994

  背景：出现拨号上网服务、同年网景推出浏览器，不在局限学术交流

  需求：支持多种文件类型下载、文件格式不局限于ASCII编码

  特点：增加请求头、响应头；引入状态码；**Cache**机制；请求头增加**用户代理**

* **HTTP/1.1**

  1999年

  **{**

  问题:下载每个文件时都需要建立TCP连接

  方案:增加持久连接，在一个TCP连接上传输多个HTTP请求，默认开启。

  **}**

  目前浏览器对于同一个域名，默认允许同时建立6个TCP连接

  **{**

  问题：持久连接导致的**队头阻塞**问题

  方案：不成熟的**http管线化**???

  **}**

  **{**

  问题：一个IP地址是可以进行多次解析的，服务器只支持一个域名

  方案：虚拟主机，多个虚拟主机域名共用一个ip地址，Host字段

  **}**

  **{**

  问题：头部需要返回content-length，动态生成的内容无法提前确定**？？？**（是否由于分片传输导致无法确定）

  方案：Chunk transfer机制

  **}**

  **{**

  问题：stateless

  方案：cookie机制、安全机制

  **}**

  域名分片机制：浏览器针对一个域名建立6个tcp连接

* **HTTP/2**

  2015年5月正式发布，**那些网站采用http/2，各大浏览器、服务器对http协议的支持实现情况？？？**

  2018年开始得到大规模的应用

  **http/1.1**存在的问题：对带宽的利用不理想

  * tcp的慢启动（刚开始tcp采用一个非常慢的速度发送数据，然后慢慢加快）；
  * 开启了多条tcp，会存在竞争，但是tcp连接之间没有优先级划分；
  * 队头阻塞使得数据不能并行请求。

  **{**

  问题：慢启动和TCP连接之间相互竞争带宽-TCP本身机制；队头阻塞是由于HTTP/1.1导致

  方案：

  * 一个域名只使用TCP长连接，阻止多次慢启动
  * 多路复用机制，支持并行请求

  **}**

  多用复用请求实现：增加了一个二进制分帧层

  ![image-20210807132604476](..\images\4.png)

  

  HTTP/2其他特性：

  设置请求优先级

  服务器推送

  头部压缩

* **HTTP/3**

  http的问题：

  * TCP的队头阻塞：TCP传输过程某个数据包丢失，造成的队头阻塞，http2中多个请求都是一个TCP管道，随着丢包率的增加，传输效率会越来越差

    当系统达到2%的丢包率，http1.1的丢包率反而比http1更好

  * TCP的延时连接，握手过程

  * TCP协议僵化，中间设备大都依赖一些很少升级的软件，这些软件使用了大量的TCP特性，被设置后就很少更新，TCP协议都是依赖操作系统内核实现的。

  QUIC协议：基于UDP协议实现类似TCP的多路数据流、传输可靠性等功能

  ![image-20210807211257732](..\images\5.png)

  HTTP/3的挑战：

  * 服务器、浏览器都没有对其提供比较完整的支持
  * 部署HTTP3也存在问题，系统内核对UDP的优化远远没有达到TCP的优化程度
  * 中间设备僵化，这些设备对UDP的优化程度远低于TCP

  

#### 2.基于abnf 的http 消息格式定义

用来描述计算机语言语法的符号集

![image-20210807003823265](..\images\1.png)

#### 3.OSI七层模型

<img src="..\images\2.png" alt="image-20210807115127882" style="zoom: 80%;" />

![image-20210807120101067](..\images\3.png)

**网络设备的分类**：？？？

数据传输的各层数据包格式

![asd](..\images\6.png)

**4.http协议解决了什么问题**

WWW信息交互面对的需求：

低门槛、可扩展性、大粒度数据的网络传输、internet规模、向前兼容

其中internet规模，意味着负载不可预测、客户端保持所有服务器信息，服务器不能保持多个请求间的状态信息（cookie）

**5.为什么会需要对URL进行编码**

url传递的参数中可能存在http中用作分隔符的保留字符，不编码会影响url解析

url传递的参数可能会产生歧义性的数据，如：不在ASCII范围内的字符、ASCII码中不可显示的字符、URI中规定的保留字符、不安全字符

怎么编码:

* ASCII码：直接编码
* 非ASCII码：先UTF编码，在US-ASCII编码

对于URI合法字符，编码与不编码是等价的

* 保留字符：： /   ?  #  [    ]   @       !   $   &   '    (   )   *   +   ,    ;    =
* 非保留字符：字母  %41~5A    %61~7A  ;  数字  30%~39%；  -（%2D）; .(%2E) ; _(%5f) ; 

**6.http解决了什么问题**

解决了什么问题，首先要看www信息交互面对了什么需求：

* 低门槛

* 可扩展性,巨大的用户群体，意味着快速迭代的需求，因此其扩展性需要非常好

* 分布式系统下的超媒体，各种media会在网络中传递，不局限于文本

* Internet规模

  * 环境复杂、负载不可预测

  * 规模庞大，且应用的规模会根据不同种场景进行伸缩，因此要求客户端不能保存所有服务器信息，服务器不能保持多个请求间的状态信息

    否则，进行扩容、缩容的时候，需要维持这些状态信息

  * 新老组件并存，各种不同版本的协议之间会在一个时间段内共存，并且进行彼此间的通信

**7.chrome devtools network面板**

过滤器中对属性过滤的几种常见用法

请求列表中initiator几种值：Parser(HTML解析器发起了请求)、重定向、脚本、Other（一些其他进程或动作请求发起请求，例如地址栏输入地址）

domain、has-response-header(包含指定响应标头的资源)、is:running（查找websocket资源）、is:from-cache(缓存读出的资源)、larger-than

method、mime-type、mixed-content(**混合内容资源？？？**)、scheme（scheme:http）、status-code、set-cookie-domain、set-cookie-name、set-cookie-value

多属性通过空格实现**AND**操作

<img src="..\images\7.png" alt="image-20210829214943107" style="zoom: 80%;" />

**8.http请求行**

request-line = method **SP** request-target **SP** HTTP-version **CRLF**

request-target = origin-form **/** absolute-form **/** authority **/** asterisk-form 

第一种最常见，表示origin-server的资源路径

第二种仅用于向正向代理proxy发起请求时（正向代理针对于客户端的请求，对客户端进行授权、过滤；反向代理则针对于服务器端的请求，如负载均衡）

第三种仅用于connect方法

第四种仅用于options方法

* 常见方法：

  GET，获取信息，大量的性能优化都针对get方法，幂等

  POST，常用于提交HTML FORM表单、新增资源等

  HEAD，类似get，但服务器不发送body，用于获取head元数据，幂等

  PUT,更新资源，带条件时是幂等

  DELETE,删除资源，幂等

  CONNECT，建立tunnel隧道

  OPTIONS：显示服务器对访问资源支持的方法，幂等

  TRACE，回显服务器收到的请求，用于定位问题，有风险

**9.http响应行**

status-line = HTTP-version  **SP**  status-code  **SP**  reason-phrase  **CRLF**

**响应码分类：**

1xx：

* 100 continue 上传大文件前使用
* 101 switch protocols 协议升级使用，客户端请求携带Upgrade：头部触发
* 102 processing，表示服务器已经收到并正在处理请求，但无响应可用，防止客户端超时

2xx：

* 200 ok，成功返回响应
* 201 created，有新资源在服务器端被创建
* 202 accepted，服务器接收并开始处理请求，但请求并未处理完成。
* 203 Non-Authoritative information：当代理服务器修改了origin server的原始响应包体，代理服务器修改200为203，203可被缓存
* 204 no content：成功执行了请求且不携带包体，同时指明客户端无需更新当前页面视图
* 205 Reset content:成功执行了请求且不携带包体，同时指明客户端无需更新当前页面视图
* 206 partial content：使用range协议时返回部分响应内容
* 207 multi-status：在webdav协议中以xml形式返回多个资源的状态
* 208 already reported：**？？？？**

3xx：重定向使用location指向的资源或者缓存中的资源，规定重定向次数不应超过5次

* 301 moved permanently，资源永久性的重定位到另一个资源
* 302 found，资源临时的重定向到另一个url
* 303 see other，重定向到其他资源，常用于POST/PUT等方法的响应
* 304 not modified，当客户端拥有可能过期的缓存时，会携带缓存表示的etag、时间等信息询问服务器缓存是否仍可复用，304告诉可以复用
* 307，类似302；308，类似301，只是要求请求方法前后需一致

4xx:

* 400 bad request,服务器认为客户端出现了错误
* 401 Unauthorized，用户认证信息确实或不正确，导致服务器无法处理请求
* 407 proxy authentication required，对需要经由代理的请求，认证信息并未通过代理服务器的验证
* 403 forbidden，服务器理解请求的含义，但没有权限执行此请求
* 404 not found，没有找到对应的资源
* 410 gone

5xx

**10.长连接、短连接**