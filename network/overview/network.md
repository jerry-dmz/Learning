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

2.connection 头部关于长连接与短链接
3.X -fowarded-to 传递原始client ip 
x -real -ip 非规范的
via 头部，max -forwards

4.请求上下文头部user -agent
refer 
file data url不会被加入
当前http 来源https 不会被加入
用途 统计分析缓存防盗链
allow 允许执行那些方法
allow-ranges是否允许range 请求
5.内容协商
主动内容协商
accept  accept-language accept-encoding 
对应content -type 等
响应式内容协商
返回300或406
6常见的协商要素
质量因子
i18n
l10n
7.包体
请求和响应都可以携带包体
某些消息不能携带包体
如head 方法

定长包体content -length 10进制表示字节数

不定长包体transfer-encoding:chunk
chunk 的格式
trailer 头部
content -disposition 
8.form 表单的提交格式
enc-type 
默认 multi/partform -data 
9.http range 规范，断点续传
允许服务器基于响应只发送部分包体到客户端，客户端自动将多个包体组装成一个完整包体
支持断点续传，支持多线程下载，支持视频实时拖动播放
if -range 
206partial content content-range 
416range 范围不对，200不支持range 请求
多重range  multipart/range 


10.cookie保存在客户端，服务端生成，可以存储在磁盘，也可以存储在内存
多个set-cookie 格式，有cookie string 描述这个cookie 属性的

cookie 的设计缺陷
第三方cookie 浏览器允许保存不安全域的cookie 比如广告图片

11.资源uri 和资源表述之间的关系
基于请求内容进行协商
条件请求:客户端携带条件信息，服务端进行条件判断并返回对应的资源表述
场景:
使缓存更新更有效率
断点续传验证
对多个进行修改的资源进行同步
条件请求验证器:
E -tag  last-modified 
Authtencation不能被代理服务器缓存
私有缓存和共享缓存
cache control
缓存新鲜度计算时间
12.重定向
Location 头部和重定向响应码

永久重定向
303   308
临时重定向
302  303  307
特殊重定向 
300协商
304 
重定向的几种区别
1ok 123456ok

复杂请求与简单请求跨域的区别
cors

access-allow-origin
Tunnel 使用http 协议传递非http 格式数据
connect 方法