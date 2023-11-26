# Nest

[Documentation | NestJS - A progressive Node.js framework](https://docs.nestjs.com/)

Under the food,Nest make use of HTTP Server frameworks like **Express**(default),and optionally can be configured to use **Fastify** as well.

Nest provides a level of **abstraction** above these common Node.js frameworks(Express/Fastify),but also **expose** their APIS **directly** to developer.

## nestjs/cli

`npm install -g @nestjs/cli`

`nest generate`快速生成各种代码片段

代码模板都在`@nestjs/schematics`中定义

##  请求传参

* `urlParam`，形如`/api/person/id`

* `query`, 形如`/api/person?name=zs&age=20`

* `x-www-form-urlencoded`,参数编码在请求体

* `applicaiton/json`

* `multipart/form-data`，用boundary分隔传输的内容

  用`FilesInterceptor`的拦截器解析`Form Data`

## IOC

一般情况下，provider通过**@Injectable**声明，然后在**@Module**的providers数组里注册的class。

默认的**token**就是class，也可以使用字符串类型的token，注入的时候需要**@Inject**单独指定。

用**useClass**指定注入的class，用**useValue**直接指定注入的对象，如果想要动态生成对象，还可以使用**useFactory**,它的参数也注入了IOC容器中的对象，然后动态返回provider对象。

可以用**useExisting**给已有的token，指定一个新的token。

## 全局模块

通过**@Global**声明，exports之后就可以在各处使用，不需要imports

provider、controller、module都支持一些**生命周期钩子**函数，都支持**async**的方式。

## AOP

将通用逻辑**分离**到切面，保持业务逻辑的纯粹性，这样切面逻辑还可以**复用、动态增删**

### Middleware

### Guard

实现**CanActive**接口，可以从context拿到请求的信息。

不能对请求、响应做修改。

### Interceptor

实现**NestInterceptor**接口，可以在controller前后加一些逻辑。

### Pipe

实现**PipeTransform**接口，可以对参数做校验、转换

### ExceptionFilter

实现**ExceptionFilter**接口，通过catch指定此filter处理那些异常。

Nest通过这种方式实现了**异常到响应**的对应关系。

## Nest注解

* @Module、@Controller、@Inject、@Injectable
* @Optional,声明注入的provider是可选的
* Global,声明全局模块
* @Catch、@UserFilters:指定exception和对应的filter
* @UsePipes、@UseInterceptors
* @SetMetadata：在class或handler添加metadata
* @Get等方法
* @Param，获取url中的参数
* @Query，获取query中参数
* @Body，获取请求body
* @Headers，获取某个或全部请求头
* @Session，获取session，需要启用express-session插件
* @HostParam，获取host里的参数
* @Request
* @Response，注入之后，需要调用response返回
* @Next，注入调用下一个handler的next方法
* @HttpCode、@Header，修改响应信息
* Redirect,指定重定向的url
* @Render，指定渲染用的模板引擎

## 自定义注解

**Reflect.defineMetadata(metadataKey, metadataValue, target, propertyKey);**

**Reflect.getMetadata(metadataKey, metadataValue, propertyKey);**

分别用于设置和获取某个类的元数据，如果最后传入了属性名，则是为属性设置元数据。

`reflect-metadata polyfill`包

**emitDecoratorMetadata**可以自动设置一些元数据，比如参数类型、返回值类型

通过装饰器给class或对象添加**metadata**，开启`ts`的**emitDecoratorMetadata**来自动添加类型相关的**metadata**。

运行时通过这些元数据来实现依赖的扫描、对象的创建。

## 模块

如何解决循环依赖的问题：**forwardRef**包裹

动态模块：import时传入参数，然后动态生成模块的内容

registry方法命名有3种约定：

* **register**,用一次模块传一次配置
* **forRoot**,配置一次模块用多次
* **forFeature**,

## multer文件上传

## Docker

`docker build`时，会把`dockerfile`和它的构建上下文打包发送给`docker daemon`来构建镜像

可指定`.dockerignore`,build时会先解析这个文件，将该忽略的文件忽略掉，然后把剩下的文件打包发送给`docker daemon`作为上下文来构建镜像。

* 使用`alpine`的镜像。
* 使用多阶段构建，只保留最后一个阶段的镜像。
* 使用`ARG`，在build时通过`--build-arg xxx=yyy`形式传入，在`dockerfile`中生效。
*   `CMD`和`ENTRYPOINT`类似，只不过CMD可以在运行时被覆盖
* `ADD`和`COPY`类似，但`ADD`会解压tar.gz

docker实现：

* `Namespace`做资源隔离，`Control Group`做容器的资源限制，`UnionFS`做文件系统的分层镜像存储、镜像合并。
* 通过`dockerfile`描述镜像构建的过程，每一条指令都是一个镜像层
* 镜像通过run跑起来，对外提供服务，会添加一个可写层（容器层）

## PM2

**Progress Manager**

**进程管理、日志管理、负载均衡、性能监控**等

如果想要多个应用或者想把选项保存下来，可以通过`ecosystem`配置文件，批量启动一系列应用

## mysql2

## TypeORM

## Redis

## 状态解决方案

### session + cookie

CSRF的问题，发起请求cookie是浏览器自动加上的。

分布式session，怎么在多台机器上持有session。

* session复制
* 将session保持在redis

cookie存在跨域的问题，ajax请求时不会携带cookie(除非设置withCredentials)。

### jwt token

保存在request header里的一段字符串，

* header，保存当前加密算法
* payload，具体数据
* verify signature，把header、payload和salt做一次加密生成

安全性问题，负载是名文。要搭配名文用，这样无法看到header。

性能问题，请求内容变多。

无法让JWT失效

## nginx

### 静态文件托管

### 动态资源的代理

反向代理：透明的修改请求、响应，实现负载均衡

负载均衡方式：

* 轮询（默认）
* weight，轮询基础上增加权重
* ip_hash,根据IP的hash分配，保证每个访客的请求固定访问一个服务器，解决session问题
* fair，按响应时间分配

正向代理：

### 灰度系统

流量通过配置走新、旧两套代码，避免大面积线上故障













































