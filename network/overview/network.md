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

1.基于abnf 的http 消息格式定义
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