## 事件循环与异步I/O

基于**libuv**,完成事件循环与异步I/O。

最初的版本中，Linux与macOS等是基于**libev与libeio**的进一步封装，多路复用则是基于**epoll或kqueue**。windows下，则使用**IOCP**。

**uv_async_t**:允许**非libuv事件循环中线程**通知libuv某个事情做完了。