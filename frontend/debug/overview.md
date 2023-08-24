## 前端调试

代码在某个平台运行，把运行时的状态通过某种方式暴露出来，传递给开发工具，辅助排查问题、梳理流程、了解代码的运行状态。

### Chrome Dev Tools

* **backEnd**,和**chrome**集成，负责将chrome的网页运行时状态通过调试协议暴露出来（**Chrome DevTools Protocol**）。
* **frontEnd**,对接调试协议，做ui的展示和交互。

传输协议的方式叫做信道，有很多种，比如**Chrome DevTools**嵌到Chrome时，两者通过**全局函数**通信；当远程调试时可以通过**WebSocket**通信。

### Vscode Debugger

原理和Chrome DevTools类似，只是多了一层适配器协议（因为vscode不仅仅是js编辑器）。**Node.js6**以上就使用**CDP**作为调试协议。

### Vue/React DevTools

#### Chrome插件机制

https://juejin.cn/post/7145845821395697695

##### mainfest.json

用于描述整个插件的架构和权限。

##### content_script(内容脚本)

Content scripts are files that run in the context of web pages.By using the standard **DOM**,they are able to read details of the web pages the browser visits,make changes to them,and pass information to their parent extension.

本质是一个**js文件**，可以使用**插件特有的API**，可以操作目标页面的**DOM**。有自己的**独立上下文环境**（运行在类似沙盒的环境中）。

##### servide worker(backgorund)

单独跑在一个线程，可以使用**插件特有的API**，监听浏览器触发的事件。

##### Popup（弹窗）

右上角小图标点击弹出的窗口，本质是一个web页面。

##### DevTools

DevTools扩展结构与其他任何扩展一样：可以有一个背景页面（background）、内容脚本和其他项目。此外，每个DevTools扩展都有一个**DevTools Page**，该页面可以访问**DevTools API**.

### Vscode Debugger配置

以开启远程**debugg**模式启动**chrome**后，http://localhost:9222/json，看到所有**ws**服务

**vscode**中用**attch**模式可以直连

**chrome --remote-debugging-port=9222**

除了启动开发服务器连上url调试，也可以指定文件调试，**Vscode Debugger**会启动静态服务器

### Source Map

Source maps offer a **language-agnostic** way of mapping **production code** to the original code that was we authored in **developmeny enviorment**.

生成Source Map的五种方式：

#### Closure Compiler

谷歌的工具，用来优化js，java编写，同样可以用来生成source map。

#### GruntJS Task for JSMin

grunt的grunt-jsmin-sourcemap插件。

#### UglifyJS

UglifyJS2 is another javascript Parser,minifier and compressor。

#### CoffeeScript Redux

CoffeeScript -> javascript -> optimised Javascript

#### TypeScript

#### SourceMap结构

```json
{
    version: 3,
    // 转换后的文件名
    file: "out.js",
    // 转换前文件所在的目录。如果与转换前的文件同一目录，该项为空。
    sourceRoot: "",
    // 转换前的文件。
    sources: ["foo.js", "bar.js"],
    // 转换前所有变量名和属性名。
    names: ["src", "maps", "are", "fun"],
    // 记录位置信息的字符串。
    mappings: "AAgBC,SAAQ;CAAEA"
}
```

* 行对应，用分号分隔，每个行号对应转换后源码的一行。
* 位置对应，用逗号分隔，每个逗号对应转换源码的一个位置。
* 位置置换。以**VLQ编码**表示，代表该位置对应的转换前的源码位置。

每个位置使用五位，表示5个字段：

* 第一位，在转换后代码的第几列
* 第二位，属于source属性中那一个文件
* 第三位，属于转换前代码的第几行
* 第四位，属于转换前代码的第几列
* 第五位，属于names属性中那一个变量

@sentry/webpack-plugin支持在打包完成后把sourcemap自动上传到sentry后台。

sourcemap只是位置的映射，可以用在任何代码上，比如js、ts、css等。

https://astexplorer.net/#/gist/19042bfa06784d0e1b2dcb2ecd3559d5/50898c658d8129dbe520cc515af169331082036b

AST中保留了源码中的位置，在转换后会打印成目标代码。

source-map包可以用于生成和解析sourceMap

### Webpack对于SourceMap配置项

最底层是浏览器支持的**文件级别的sourcemap**,**eval代码的source映射和sourcemap**两种机制。

可以依据^(inline-|hidden-|evel-)?(nosources-)?(cheap-(module-)?)?source-map$形式字符串来配置**devtool**

也可以**关闭devtool**,启用**SourceMapDevToolPlugin**来配置。

* **eval**：浏览器devtool支持通过sourceurl来把evel的内容单独生成文件，还可以进一步通过sourceMappingUrl来映射回源码。WebPack利用这个特性简化了sourcemap的处理，可以直接从模块开始映射，不用从bundle级别。
* **cheap**：只映射到源代码的某一行，不精确到列，可以提高sourcemap的生成速度
* **source-map**:生成source-map文件，可以配置inline，会以**dataURL**的形式内联，可以配置hidden，只生成sourcemap,不和生成的文件关联
* **nosources**:不生成sourceContent，可以减小sourcemap文件的大小。
* **module**：sourcemap生成时会关联每一步loader生成的sourcemap，可以映射会最初的源码。

### 调试Vue项目

vue-cli默认devtool设置为**eval-cheap-module-source-map**

生成的**source-map**为：

```javascript
//# sourceURL=[module]
//# sourceMappingURL=...
//# sourceURL=webpack-internal
```

第一个sourceURL的路径是通过[module]指定的，而模块名后默认带?hash，因此在无法直接在vscode中打断点（因为路径多了?hash，会到找不到）

vscode里打的断点会被传递给浏览器，本地打的断点是一个绝对路径，包含了${workspaceFolder}的路径，网页里没有这个路径，网页里的文件关联了sourcemap，会把文件路径映射到源码路径。如果映射不到本地文件，会导致断点打不上，此时可能就需要修改launch.json的**sourceMapPathOverrides**配置来正确处理映射。

### 调试React源码

TODO：涉及到其构建过程，较复杂，专门用一个专题处理吧。

#### 调试Vue源码

提供了支持，需要调试的时候，直接调试即可

### 调试Node.js代码

* node --inspect-brk ./index.js,然后在chrome://inspect中即可调试
* 创建lanch.json来调试，选择lanch program调试项

#### nodejs debugger

最早的调试协议为**V8 Debug Protocol**,**node debug ./index.js**会在首行断住，然后用命令调试

然后，node debug服务，还要起一个node inspector服务用于转接CDP和VDP协议

最后，把v8 inspector集成到nodejs中（这个是从chrome的内核blink中剥离出来的）。废弃node debug，替换成node --inspect

vscode中调试只支持**debugger adpter protocol**，其他只要实现这个adpter即可使用通用的调试功能。

### Lanch.json

https://code.visualstudio.com/Docs/editor/debugging

ctrl + space查看所有属性

* autoAttachChildProcess 调试模式启动时，主进程有调试端口，子进程也会有调试端口，这个选项为true时会自动连接上子进程的端口。

### 各种npm包管理工具

cnpm yarn pnpm等工具都是基于npm管理器的一些变种，解决了npm早期的一些缺点。

* npm@v1.0.0 首次发布 -- 2010
* npm@v3.0.0 node_modules目录结构扁平化（将所有依赖都提升到顶层平铺）-- 2015年6月
* npm@v4.0.0 packge-lock.json前身npm-shrinkwrap.json用于依赖锁定 -- 2016年10月
* npm@v5.0.0 packge-lock.json默认生成，并兼容npm-shrinkwrap.json,重构npm-cache -- 2017年05月
* npm@v5.2.0 npx命令发布 -- 2017年7月
* npm@6.0.0 增加npm init -- 2018年5月

#### yarn

* 支持离线安装
* 依赖扁平化
* 依赖安装确定性
* 速度快、并行下载，支持失败自动重试

#### pnpm

通过链接的方式，使多个项目的依赖用同一个包，节约了磁盘空间。

#### npx

* 调用项目内部安装的模块，会到**node_moodules/.bin**路径和**$PATH**去找。
* 避免安装全局模块，例如**npx create-react-app project1**，会将**create-react-app**安装到一个临时文件目录，使用后在删除。
* 使用不同版本的node，**npx node@0.12.8 -v**。
* -p参数，**npx -p lolcatjs -p cowsay [command]**,指定要安装的模块，然后执行后面的命令。
* -c参数，**npx -p lolcatjs -p cowsay -c 'cowsay hello | lolcatjs'**,让所有命令都用npx解释。

### npm scripts

命令行工具的package.json里都会有bin字段，声明字段。install之后会放到node_modules/.bin目录下。

### 命令行工具的调试

#### eslint

npx eslint ./index.js

使用api方式调试eslint

#### patch-package

和pnpm内置patch、patch-commit命令类似

创建临时packgage.json,执行install，然后将包复制过去，根据修改内容生成diff文件。

#### babel

@babel/parser、@babel/traverse、@babel/generator

vscode的**resolveSourceMapLocations**默认配置不会到node_modules下查找sourceMap

#### vite

修改build过程，构建sourceMap

https://pnpm.io/zh/package_json

#### typescript

sourceMap是对的，但是就是无法在ts文件中打上断点。

#### Ant Design

组件先后经过了tsc、babel的编译，最后webpack打包成bundle.js，ts和babel的编译都会生成sourcemap，webpack也会生成sourcemap。webpack的sourcemap默认只会根据最后一个loader的sourcemap生成。需要将**devtool**设置为cheap-module-source-map,来关联loader的sourcemap。

### launch.json支持的变量

${file} 当前打开文件

${cwd} 当前执行命令的工作目录

......

可以通过${env:PATH}取环境变量

可以通过${config:editor.fontSize}取vscode配置中值

可以执行vscode命令获取它的返回值${command:extension.pickNodeProcess} 

### Performance工具

TODO：

### Web Vitals

* **TTFB**（Time To First Byte）,开始加载网页到接受第一个字节网页内容之间的耗时。

  performance api或PerformanceObserver可以获取相关指标

* **FP**（First Paint），第一个像素绘制到页面上的时间。

* **FCP**（First Contentful Paint），从开始加载网页到第一个文本、图像、svg、非白色的canvas渲染之间的耗时

* **LCP**（Largest Contentful Paint），最大内容（文字或图片）渲染的时间。

* **FMP**（First Meaningful Paint），首次有意义的绘制，<video elementtiming="meaningful"/>,即可统计。

* **DCL**（DomContentLoaded）,文档被完全加载解析完，无需等待stylesheet、img和iframe的加载完成。

* **L**（Load），html加载解析完，它依赖的资源也加载完

* **TTI**（Time to Interactive），可交互时间

* **FID**（First Input Delay），用户第一次与网页交互到网页响应事件的时间

* ........

### Layers

为什么分不同的图层：页面不同部分重绘频率不一样，如video、canvas、动画就要高频重绘，而且现代浏览器还支持通过GPU做计算来加速渲染。

### Chrome dev Tools其他功能

* 手动关联**sourceMap**
* **filter**,输入**-**，会提示出所有能用的过滤器，中间加空格，代表组合多个过滤器。ctrl+f还可以搜索请求的内容









