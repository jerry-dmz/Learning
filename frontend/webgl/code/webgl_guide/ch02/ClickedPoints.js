// Vertex shader program
/**
 * attribute变量只能在顶点着色器中使用
 * WebGL内置变量:
 * gl_Position:顶点位置坐标vec4
 * gl_PointSize:点渲染模式，方形点区域渲染像素大小float
 * gl_FragColor:片元颜色值vec4
 * gl_FragCoord:片元坐标vec2
 * gl_PointCoord:点渲染模式对应像素坐标vec2
 * TODO:各内置变量的使用场景
 */
var VSHADER_SOURCE =
  'attribute vec4 a_Position;\n' +
  'void main() {\n' +
  '  gl_Position = a_Position;\n' +
  '  gl_PointSize = 10.0;\n' +
  '}\n';

// Fragment shader program
var FSHADER_SOURCE =
  'void main() {\n' +
  '  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n' +
  '}\n';

function main() {
  // Retrieve <canvas> element
  var canvas = document.getElementById('webgl');

  // Get the rendering context for WebGL
  var gl = getWebGLContext(canvas);
  if (!gl) {
    console.log('Failed to get the rendering context for WebGL');
    return;
  }

  // Initialize shaders
  if (!initShaders(gl, VSHADER_SOURCE, FSHADER_SOURCE)) {
    console.log('Failed to intialize shaders.');
    return;
  }

  /**
   * 获取shader中定义attribute变量的位置
   */
  var a_Position = gl.getAttribLocation(gl.program, 'a_Position');
  if (a_Position < 0) {
    console.log('Failed to get the storage location of a_Position');
    return;
  }

  // Register function (event handler) to be called on a mouse press
  canvas.onmousedown = function (ev) { click(ev, gl, canvas, a_Position); };

  // 指定背景色之后，会常驻WebGL
  gl.clearColor(0.0, 0.0, 0.0, 1.0);

  // 继承Open GL，基于多基本缓冲区类型，清空颜色缓冲区
  gl.clear(gl.COLOR_BUFFER_BIT);
}

var g_points = []; // The array for the position of a mouse press

function click(ev, gl, canvas, a_Position) {
  /**
   * 此处的处理，canvas的坐标系和WebGL坐标系的差异，因此要做转换，得到webgl中的坐标
   */
  var x = ev.clientX; // x coordinate of a mouse pointer
  var y = ev.clientY; // y coordinate of a mouse pointer
  var rect = ev.target.getBoundingClientRect();

  x = ((x - rect.left) - canvas.width / 2) / (canvas.width / 2);
  y = (canvas.height / 2 - (y - rect.top)) / (canvas.height / 2);
  // Store the coordinates to g_points array
  g_points.push(x); g_points.push(y);

  // TODO:绘制之前，清空缓冲区
  /**
   * 绘制点之后，颜色缓冲区被WebGL重置为默认的颜色（0.0,0.0,0.0,0.0）
   * 如果不希望这样，应当在每次绘制之前都调用gl.clear()来用指定的背景色清空。
   */
  gl.clear(gl.COLOR_BUFFER_BIT);

  var len = g_points.length;
  /**
   * 如果绘制模式为gl.POINTS的时候，一个只能绘制一个点
   */
  for (var i = 0; i < len; i += 2) {
    // Pass the position of a point to a_Position variable
    gl.vertexAttrib3f(a_Position, g_points[i], g_points[i + 1], 0.0);

    // Draw
    gl.drawArrays(gl.POINTS, 0, 1);
  }
}
