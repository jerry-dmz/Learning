学习要有目的性。

没有目标会没有动力，目标太大会让人心生沮丧，目标不合适也只是浪费时间。

抛开外界的干扰，专注你想要成为一个什么样的人，有哪些必须达成的目标。有没有一件事能够让你废寝忘食的去做，有没有一个能够为之奋斗终身的目标。

算了，没啥好说的，干就完了，先活下来在说吧，从每周给自己一个惊喜开始吧。

## RoadMap

基本理念-->基本用法--源码解析-->项目实战

# 《现代React Web开发》

## GUI设计

* 可用性，“别让我思考”，自解释。
* 一致性，“单一界面标准”。
* 遵循用户心智模型，避免实现模型。
* 最小惊讶原则。
* 及时反馈，任何情况都要避免GUI冻结而无法操作的情况。

## 前端开发

一般业界实战中，一个相对复杂的前端应用可能会同，时包含多个**SPA**，最终以**MPA**多页应用的形式提供给用户。

相比其他软件开发领域，前端本身会为开发者提供及时的**正反馈**。

**从整体到局部，从简单到复杂，从视图到交互，从数据到逻辑**

## React生态

做好声明式、组件化、单向数据流，以及hooks,其他领域留给第三方。

* 类MVC框架，早期的React侧重视图，并没有内置的`dispatch`、`reducer`，开源社区为React设计的应用状态管理框架如**Redux、Flux**
* 服务器通信，**React Query**
* 表单处理，**Formik、React Hook Form**
* 前端路由：**react-router**
* 其他打包插件、脚手架工具、测试框架

## jsx

### 需求

web应用开发中，视图中包含很多逻辑控制，以**声明式**开发视图，需要将**控制逻辑加入到视图中**。

jsx是`createElement`的**语法糖**，组件是react开发的**基本单位**，组件中，需要**被渲染的内容**是用`React.createElement(component,props,...children)`声明的。jsx会被编译成一系列`createElemnt`组成的js代码。

web领域，类html语法天生更受欢迎。其他的模板技术，如thmeleaf、jsp，都是用**xml定义了一套标签库的DSL**，而**JSX则直接利用了js语句**，而不要去学习一套新的DSL。

**J**ava**S**cript **X**ml，在js语言里加入类XML的**语法扩展**。

* 标签的命名规则，支持的元素类型、子元素类型
* 可以写那些js表达式、规则

### JSX元素类型

* React封装的DOM元素，直接渲染为最真实的DOM

  将浏览器DOM整体做了一次面向React的标准化。

* React组件渲染的元素，会调用对应组件的渲染方法

  jsx中的props应该和子组件定义中的props对应起来。

* React Fragment元素，没有实际业务意义，也不产生额外的DOM

* ...

### JSX子元素类型

jsx元素可以指定**子元素**。子元素不一定是子组件，子组件一定是子元素。

* 字符串，最终被渲染成HTML标签里的字符串
* 另一段JSX，会嵌套渲染
* js表达式，会在渲染过程中执行，并让返回值参与到渲染过程
* 布尔值、null、undefined，不会被渲染出来
* 以上各种类型组成的数组

### JSX中JS表达式

用```{}```包裹，主要用在：

* ```<button disabled={showAdd}>按钮</button>```，作为**props**值
* ```<div className="card">{title}</div>```,作为jsx元素的子元素。

类组件->无状态函数式组件

刚开始，函数式组件需要在父组件中提供状态，并通过props传递，开源社区开发了各种支持库，用诸如高阶组件的方式补足函数组件缺失的功能，如**recompose**

到了v16.8，Hooks发布，函数式组件成为主流：

* ```UI=f(state)```
* 更彻底的关注点分离
* 函数式编程

## 组件化

组件是对视图以及与视图相关的逻辑、数据、交互等的封装。

组件拆分并无绝对的标准，拆分时，需要理解业务和交互，设计**组件层次结构**，以关注点分离原则校验每次拆分。

### 组件层次结构

面向对象编程中，一般是指继承关系。React并没有用类继承的方式扩展组件（类组件继承React.Component类，但类组件之间没有继承关系）。

组件层次结构可以将前端应用需要承担的业务和技术复杂度分摊到多个组件中去，并把这些组件拼装到一起。

真.子组件的设计模式：Semantic UI React、Recharts

对中小型应用，更倾向于从上到下拆分；面对大型应用，更倾向于从下往上拆分。

* 单一职责
* 关注点分离
* 一次仅一次
* 简约原则

拆分组件时：

* 没必要一次性拆分彻底，具体实现过程依然可以继续拆分
* 没必要追求绝对正确，后续开发中可以根据需要，随时调整

## 虚拟DOM

面向前端开发者，React提供包括JSX语法在内的声明组件API。

在运行时，开发者声明的组件会渲染成虚拟DOM，虚拟DOM再由React框架渲染成真是DOM

虚拟DOM的变动，最终会自动体现到真实DOM上

真实DOM上的交互，也会由React框架抽象成虚拟DOM上的副作用（Side-effect）

### Diff算法

* 从根元素开始，递归对比两棵树的根元素和子元素
* 对比不同类型的元素，会清理旧的元素和它的子树，然后建立新树
* 同为html元素，但tag不同的元素，会清理旧的元素和子树，然后建立新树
* ...

数据发生了变化，React就会对当前组件触发协调过程，最终按Diff结果更改页面

* ```props```，组件外部传递进来的
* ```state```，活跃在组件内部
* ```context```,在组件外面的Context.Provider提供数据，组件内部可以消费context数据。

```FiberNode```:依靠对元素到子元素的双向链表、子元素到子元素的单向链表实现一棵树，这棵树可以随时暂停并恢复渲染，出发组件声明周期等副作用，并将中间结果分散保存在每一个节点上，不会block浏览器中其他工作。

## 为什么抛弃类组件

[为什么 React 现在要推行函数式组件，用 class 不好吗？ - 知乎 (zhihu.com)](https://www.zhihu.com/question/343314784)

* Hooks是比HOC和render props更优雅的逻辑复用方式

  高阶组件HOC和render props一样，是为了给纯函数组件加上state，响应react的生命周期

  HOC通过封装一个类组件持有组件，为函数式组件添加功能、状态

  render props则通过一个函数将class组件的state作为props传递给纯函数组件

* 函数式组件更加”声明式“，hooks取代了声明周期的概念

  类组件中，要在各种声明周期检查props、state，触发对应的副作用

  函数式组件中，在开头用hooks声明了”组件具备的副作用，副作用依赖的数据“，从命令式转变为声明式

* 函数式组件更加”函数式“，为未来的并发模式打下基础。

函数式组件依然是 **外部数据 => view**的映射,依然是pure function的心智模型。只不过，现在外部数据不仅仅包括props和context，还包括**state**

react对hooks的种种限制，就是为了把useState等hooks声明在函数组件开头，useState状态声明概念上就相当于静态声明，不会因**props这种运行时因素的变化而改变**。

useState得到的状态，对于组件来说是一种外部传入的数据，和```porps```、```context```没有本质的区别。useState声明的状态，实际由React内核进行维护，注入给函数式组件。

React渲染过程的本质：根据数据模型（**应用状态**）计算出视图内容。

组件纯化之后，开发者编写的组件树其实就是**应用状态=>DOM结构**的纯函数。而应用状态实际由React内核维护，所以React内核可以维护**多份**数据模型，**并发渲染**“**多个版本**”的组件树。

[youtu.be](https://youtu.be/nLF0n9SACd4?t=481)

## 组件样式

### CSS-in-JS

CSS尚不具备现代前端组件化开发所需要的部分领域知识能力，需要其他技术来补足。

* 组件样式的作用域需要控制在组件级别。
* 组件样式与组件需要在源码层面建立更强的关联。为什么？？？
* 组件样式需要响应组件数据变化。
* 组件样式需要有以组件为单位的复用和扩展能力。

#### ```emotion```

**css**`args`，将` `定义的模板字面量直接拼在函数名后是ES6新加入的语法，称**带标签的模板字符串**。

**Vendor Prefix浏览器引擎前缀**：浏览器厂商通过这种方式引入**尚未标准化的、实验性的CSS属性或属性值**

```css
<section css={css`
	display:flex;
    & > h2 {
        margin:5;
        
        & > button {
            padding:7
        }
    }
`}>
```

嵌套选择器不是`emotion`独创的语法，早期在**LESS**、**SASS**等CSS预处理器就已经支持。W3C将其吸纳，形成了**CSS Nesting**标准草案，在CSS-in-JS框架中普遍加入这一语法。

往CSS里传JS数据，会导致`emotion`在运行时**创建大量的```<style>```标签**。

除了用模板字面量，还可以选择**Object Styles**的方式，即JS对象的属性名和属性值来写CSS。

```Style-components```,不依赖于编译，本身就提供组件化的API。

```CSS Modules```,在各种前端编译工具都支持，只是做**CSS样式隔离**。

```css
/** Component.module.css */
.container {
    width: 100px;
    background-color: blue;
}
```

```jsx
//Component.jsx
import Styles from './Component.module.css';

const Component = () => {
    <div className={Styles.container}>Test</div>
}
```

编译后：

```html
<div class="component-module__Component--zTpG1">
    Test
</div>
```

CSS-in-JS能帮助做样式隔离、提升组件样式的可维护性、可复用性

具体体现在哪儿？？？

## 组件生命周期

在React里，组件生命周期**并不等同于类组件的生命周期方法**。

组件生命周期是一组抽象概念，类组件生命周期和Hooks API都可以看做这个概念的对外接口。

### 类组件生命周期

* 挂载

  * 组件构造函数，为state设置初始值，绑定this实例
  * ```static getDerivedStateFromProps```。如果类组件定义此静态方法，在挂载过程会调用，根据返回值设置```state```
  * ```render```,在挂载过程会调用此方法获得组件元素树。
  * ```componentDidMount```,首次完成DOM树的创建，会调用这个方法，此处可以访问真实的DOM元素，也可以调用```this.setState```出发再次渲染。

* 更新

  * ```static getDerivedStateFromProps```。只要渲染组件，都会调用此方法
  * ```shouldComponentUpdate```。
  * ```render```。
  * ```getSnapshotBeforeUpdate```。本次真实更新DOM之前调用。
  * ```componentDidUpdate```。完成更新时会调用此方法。

* 卸载

  * ```componentWillUnmount```。清理定时器、取消不受React管理的事件订阅等。

* 错误处理阶段

  组件在渲染时、执行生命周期方法、执行hooks时，进入**错误处理阶段**

  如果组件本身定义了```static getDerivedStateFromError```和```componentDidCatch```这两个方法其中一个，这个组件就成了**错误边界**，会被React调用来处理错误。

  如果当前组件不是错误边界，就会找父组件；如果父组件也不是，会继续往上，直到根组件，如果没有，应用就出异常。截至到v18.2.0,只有类组件才能成为错误边界，函数组件不行。

渲染阶段是**异步过程**。主要负责更新**虚拟DOM**，而不会操作真实DOM，这一过程可以被React暂停、恢复，甚至并发处理，因此要求渲染阶段的生命周期方法必须是**没有任何副作用的纯函数**。

提交阶段是**同步过程**。根据渲染阶段的比对结果修改真实DOM，这一阶段的生命周期方法可以包含副作用。

### 函数组件生命周期

React在**渲染阶段**根据组件函数的返回值创建FiberNode树。**提交阶段**，```React```更新真实DOM之前会依次执行前面定义的Effect。

* 挂载阶段。执行组件函数，遇到`useState`、`useMemo`等`hooks`依次挂载到`FiberNode`上，`useEffect`也会被挂载，但包含的副作用会保留到提交阶段。
* 更新阶段。当调用`useState`返回的`setter`修改了状态，组件进入更新阶段，组件函数会被**再次执行**。Hooks会依次于FiberNode上已经挂载的Hooks匹配，并根据需要更新。
* 卸载阶段。主要执行Effect的清除函数。

函数组件的错误处理依赖于祖先组件提供的错误边界。

## Hooks

hooks是React实现组件逻辑的重要方式。可以用来操作state，定义副作用，更支持开发者自定义Hooks。在使用上也有限制。

```UI = f(state)```,其中```UI```是视图，```state```是应用状态，`f`则是渲染过程。**函数组件更加贴近这一模型**，但从功能上看，早期函数组件功能与类组件有不小差距。

在React v0.14、v15、v16（v16.8.0之前）版本时，先后有**mix-in**、**高阶组件**、**recompose**框架来弥补这个差距。直到v16.8.0推出hooks。

**纯函数**：

* 重复调用时，只要入参相同，返回值就相同，这一过程不受外部状态或IO操作的影响。
* 调用时不会产生**副作用**，即不会修改入参、不会修改外部状态、不会出发IO操作，也不会调用其他会产生副作用的函数。

为函数组件设计，用于访问**React内部状态或执行副作用操作**，以函数形式存在的React API。

**PureComponent**:

用于性能优化，当组件的props和state没有变化时，将跳过此次渲染。

而函数组件，每次在渲染阶段都会被执行，如果返回元素经过协调引擎比对后，如果与前一次没有差异，则在提交阶段不会更新对应的真实DOM。

使用hooks注意项：

* 只在最顶层使用hook，不要在循环、条件或嵌套函数中调用
* 只在React函数中调用hook，不在普通js函数中调用

### useState

``````typescript
const [show,setShow]=useState(true);
``````

每次组件更新，在**渲染阶段**都会**再次**调用这个**useState**函数，但不会重新初始化`state`,而是保证`show`值，而是保证值是最新的。

此hook可以传递一个值或一个初始化函数，传递函数时，只会在**组件挂载时执行一次**这个函数，此后组件更新时不会再执行。

`useState`返回的更新函数调用后，组件的更新是异步的，react18中，为更新state加入了**自动批处理**特性，多个state更新调用函数合并到一次重新渲染中。

因此，只有下次渲染时，state变量才会更新为最新值，如果希望每次更新state时都要基于当前state值做计算，调用更新函数就需要`**setShow(prevState>{})**`,就可以保证更新函数使用最新的state。

### useReducer

```javascript
function reducer(state, action) {
    switch(action.type) {
        case 'show':
            return true;
        case 'hide':
            return false;
    }
}
function App() {
    const [show,dispatch] = useReducer(reducer, false);
    dispatch({type:'show'});
}
```

`useState`底层就是基于`useReducer`实现的，适用于抽象封装复杂逻辑。

### useEffect

```javascript
useEffect(()=>{},[var1,var2]);
```

组件渲染时会被调用，但作为参数的副作用回调函数在**提交阶段**才会被调用，这时可以访问到**组件的真实DOM**。

组件渲染时，会记录当时的依赖值数组，下次渲染时会把依赖值数组里的值一次与前一次记录下来的值做**浅对比**。如果有不同，才会在提交阶段执行副作用回调函数。

依赖值数组可以加入`props`、`state`、`context`值。

**`[]`**也是一个有效的依赖值数组，只会在组件挂载时执行一次。

### useMemo

```javascript
const memoized = useMemo(() => createByHeavyComputing(a,b), 依赖值数组);
```

为工厂函数返回一个记忆化的计算值，在两次渲染之间，**只有依赖数组中依赖值发生变化**，该Hook才会调用工厂函数重新计算值。

### useCallback

```javascript
const memoizedFunc = useCallback(() => {}, 依赖值数组);
```

把第一个参数的回调函数返回给组件，只要第二个参数依赖值数组的依赖项不变，就保证一直返回**同一个回调函数**；相反，才会**更新回调函数及其闭包**。

## 事件处理

合成事件是对原生DOM事件的一种包装，**与原生事件接口相同**，根据W3C规范，React内部**规范化**了这些接口在不同浏览器之间的行为。

React使用了**事件代理模式**。在createRoot时，会在**容器上监听所有**自己支持的原生DOM事件。当原生事件出发时，React会根据事件的类型和目标元素，找到对应的FiberNode和事件处理函数，**创建相应的合成事件**并调用事件处理函数。

“**受控组件**”：以**React state为单一事实来源**，并用React**合成事件**处理用户交互的组件

一般使用合成事件就够了，使用原生DOM事件的场景：

* React组件树之外的DOM节点事件，包括window、document对象事件
* 第三方框架，尤其是与React异构的框架，在运行时会生成额外的DOM节点，在React整合这类框架时，常会有非React的DOM侵入React渲染的DOM树

## 数据流

函数响应式编程：利用**函数式编程的部件**进行**响应式编程**的编程范式。

响应式编程将程序逻辑建模成为在**运算之间流动的数据及其变化**。

### props

自定义react组件接受一组输入参数，用于改变组件运行时的行为，这个参数就是props

类组件的props可以通过`this.props`获取。

`props`不可变，在其他组件中使用子组件时，可以通过JSX语法为子组件的props赋值。

`porps`为true时，可以简写。有一个代表子元素的props：`children`

jsx中key属性、ref，不属于props，在子组件中是不能读取传给他的key或ref的。

`props`的流向是单向的，只能从**父组件流向子组件，不能从子组件流向父组件，不能流向平级组件**。

### state

对于一个函数组件，每次渲染函数体都会重新执行，函数体内变量也会被重新声明，如果需要组件在生命周期有一个“**稳定存在**”的数据，就需要为组件引入专有的概念**state**。

`state`是不可变的，需要修改时，不能直接赋值，必须调用对应的更新函数。

当`state`变化时，组件重新渲染，React框架用`Object.is()`判断是否改变。当新旧值都是对象、数组、函数时，判断依据是它们的值引用。

当读取和更改state都发生在同一组件中时，state**流动仅限于**当前组件之内。

如果希望子组件或后代组件更改state，需要将**对应的state更新函数包在另一个函数**，比如事件处理函数，然后将函数以props或context的方式传递给子组件或后代组件，由它们决定调用的时机或参数。

### context

`context`的数据流向也是单向的，只能从**声明了`Context.Provider`的当前组件传递给它的子组件树**。

用于组件**跨越**多个组件层次结构，向后代组件传递或共享"**全局**"数据。

```jsx
const myContext=React.createContext("初始值");
function Component() {
    const [state1, setState1] = useState('文本');
    const handleClick = () => {
        setState1('更新文本');
    }
    return (
    	<myContext.Provider value={state1}>
        	<ul>
            	<ChildComponent />
                <li><button onClick={handleClick}>更新state</button></li>
            </ul>
        </myContext.Provider>
    );
}
function ChildComponent() {
    return (<GrandChildComponent />);
}
function GrandChildComponent() {
    const value = useContext(myContext);
    return (
        <li>{value}</li>
    );
}
```

其中`myContext.Provider`可以嵌套使用，后代组件会去到组件树，从它的祖先节点找到离它最近Provider。

只有上述三种数据的**变更**会**自动**通知到React框架，触发组件必要的重新渲染。可以通过**声明这三种数据来设计React应用的数据流，进而控制应用的交互和逻辑**

不应该为了重构而重构，除非很清楚重构的**目标范围、预期收益、成本和存在的风险**。

常见的代码约定：希望与文件同名的组件是这个文件的默认导出项。

## 接口

接口是抽象。“在计算机科学里，所有问题都可以通过引入一个新的抽象层解决，除了抽象层过多这个问题本身”。

* 用途广泛
* 容易被滥用
* 即使有被滥用的风险，但重要性依旧是不可替代的。

接口是边界。

* 接口是为外部设计的。
* 接口对外隐藏了实现。
* 接口调用者只需要知道接口的用法。
* 接口实现时，与外部环境的交互应集中体现在接口上。

接口是契约。

### React接口设计

#### 状态提升

#### 属性钻取

## CRA

`npm run eject`

用vite搭建react的开发环境

## 不可变数据

创建之后，就不可以再被改变。在编程和调试时更容易预测，有利于降低复杂性。

* 只能在创建时为属性赋值
* 整个对象树不可变
* 变更不可变数据只能通过创建新对象

在React中的好处：

* 编写纯函数更容易
* 避免函数对入参的一些副作用
* 检测数据变化更快
* 缓存不可变数据更安全
* 保存一份数据的多个版本变得可行

```jsx
const pureComponent = React.memo(component,compare);
```

第一个参数函数组件、类组件皆可，返回一个作为高阶组件的纯组件，**这个组件接受的props和原组件相同**。每次就会浅对比新旧props，如果相同则跳过此次渲染。此时原组件内部不要有state、context操作。

### Immutable.js

```javascript
const {List} = require("immutable");
const list1 = List([1,2]);
const newList=list1.push(3,,4,5);
```



可持久化数据结构：在修改后保留其历史版本

**Immer**:使开发者使用原生js数据结构，和本来不具备不可变性的JS API,创建和操作不可变数据。

```javascript
import produce from 'immer';
const nextState = produce(baseState, draft => {
    draft[1].done = true;
    drfat.push({title: "about"});
});
```

## 应用状态管理

### Redux

用于JS应用、可预测的状态容器，**非React**专用。

```javascript
import {createStore} from redux;
function cardListReducer(state = [], action) {
    switch(aciton.type) {
        case 'card/add': {
           return {action,newCard,...state};
        }
        case 'card/remove': {
           return state.filter(card => card.title !== action.title);
        }
        default:
            return state;
    }
}

const store = createStore(cardListReducer);
store.subscribe(() => {});

store.dispatch({type:"card/add", newCard:{title: '开发任务1'}});
```

#### 核心概念

* 动作`action`,具有`type`的简单js对象，用于表达一种意图或事件。
* 规约器`reducer`,纯函数，接受当前状态和`action`作为参数，根据`action`不同，返回与不同变更过程相当的新状态；
* 存储`store`,**应用状态**的容器，通过`reducer`返回的初始值创建，通过`store.getState()`返回最新的状态，也可以通过`store.dispatch`,接受外部使用者订阅状态的变化。

#### 基本原则

* **单一事实来源**，全局只有一个store，里面包含了唯一的状态对象树
* **状态只读**，只有通过派发action的方式才能触发reducer
* **状态变更不应有副作用**，`reducer必须是纯函数`

### Redux Toolkit

```javascript
import {createSlice, configureStore} from "@reduxjs/toolkit";
const cardListSlice = createSlice({
    name: "cardList",
    initialState: [],
    reducers: {
        addCard(state, action) {
            state.unshift(action.payload.newCard);
        },
        removeCard(state, action) {
            ...
        }
    }
});
    
export const {addCard, removeCard} = cardListSlice.actions;
                                  
const store = configureStore({
	reducer: cardListSlice.reducer                                  
});

store.subscribe(() => {});
store.dispatch(addCard({newCard: {title: '开发任务1'}}));
```

`slice`:一组相关的state默认值、action、reducer的集合。

### 其他状态管理框架

#### MobX

#### XState

### 应用中状态

* 业务状态：与业务直接相关，理论上剥离ui也可以使用
* 交互状态：用用户交互相关，控制用户与应用交互过程
* 外部状态：例如window.location、History API

什么情况下使用`Redux`

预期项目规模会逐渐增大，或者项目已经是大中型的体量，此时考虑引入Redux，鼓励全局只有单一store，比较适合管理全局状态。尤其是，要把项目中大部分组件的state都提升到**根组件**上时。

**Redux**可以**独立开发、测试**，将公用的数据流抽象出来后，可以降低根组件state的复杂度，编写Redux数据流时也可以做到与React组件的关注点分离。

**Redux**对状态的变更和读取也是解耦的	

#### React Redux

#### Redux DevTools

* 全局、业务状态倾向于放到Redux store中
* 局部、交互状态倾向于放到React state中
* 必要时，可以把外部状态同步到Redux store中

## React数据类型检查

### typescript

### PropTypes

曾内置于React框架中，提供一套DSL来定义props数据结构。

```javascript
import PropTypes from 'prop-types';
function Component({name}) {
    return (<div>{name}</div>)
}
Component.propTypes = {
    name: PropTypes.string
}
```

### Flow

针对javascript代码的静态类型检测器。

### JSDoc

```javascript
/**
 * @param {string} color1
 * @param {string} color2
 * @return {string} 
 */
export function blend(color1, color2) {}
```

## 代码复用

抽象可以用来**降低程序的复杂度**，是的开发者可以专注处理少数重要的部分。

React中两种主要的抽象方式：自定义hooks、组件组合。

### 自定义hooks

当hooks**组合**满足一定业务逻辑时，可以根据需要把它们提取为自定义hooks

### 组件组合

React组件一般以**组合**方式应对大部分扩展需求

#### 高阶组件





