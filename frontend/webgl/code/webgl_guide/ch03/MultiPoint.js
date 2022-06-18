// MultiPoint.js (c) 2012 matsuda
// Vertex shader program
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

  // Write the positions of vertices to a vertex shader
  var n = initVertexBuffers(gl);
  if (n < 0) {
    console.log('Failed to set the positions of the vertices');
    return;
  }

  // Specify the color for clearing <canvas>
  gl.clearColor(0, 0, 0, 1);

  // Clear <canvas>
  gl.clear(gl.COLOR_BUFFER_BIT);

  // Draw three points
  //第二个参数指定从哪个点开始，第三个参数执行顶点着色器执行多少次
  /**
   * 第一个参数:绘制模式
   * 第二个参数:从哪个顶点开始绘制
   * 第三个参数:绘制需要用到多少个顶点
   */
  gl.drawArrays(gl.POINTS, 0, n);
}

/**
 * 使用缓冲区的步骤
 * 1.创建缓冲区:buffer=gl.createBuffer
 * 2.指定缓冲区用途:gl.bindBuffer(gl.ARRAY_BUFFER,buffer)
 * 3.往目标写数据:gl.bufferData(gl.ARRAY_BUFFER,data,gl.STATIC_DRAW)
 * 4.将缓冲区设置给变量:gl.vertexAttribPointer(存储位置,每个顶点分量个数,数据类型,是否归一化,,)
 * 5.激活变量:gl.enableVertexAttribArray
 */
function initVertexBuffers(gl) {
  //类型化数组，提高浏览器处理效率
  var vertices = new Float32Array([
    0.0, 0.5, -0.5, -0.5, 0.5, -0.5
  ]);
  var n = 3; // The number of vertices

  // Create a buffer object
  var vertexBuffer = gl.createBuffer();
  if (!vertexBuffer) {
    console.log('Failed to create the buffer object');
    return -1;
  }

  /**
   * 缓冲区用途
   * gl.ARRAY_BUFFER表示缓冲区对象中包含了顶点的数据
   * gl.ARRAY_ELEMENTS表示缓冲区对象中包含了顶点的索引值
   */
  gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
  /**
   * 不能直接向缓冲区写入数据，只能向"目标"写入数据
   */
  //gl.STATIC_DRAW表示程序将如何使用存储在缓冲区对象中的数据，这个参数将帮助WebGL优化操作
  //就算传入了错误的值，也不会终止程序
  gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

  var a_Position = gl.getAttribLocation(gl.program, 'a_Position');
  if (a_Position < 0) {
    console.log('Failed to get the storage location of a_Position');
    return -1;
  }
  // Assign the buffer object to a_Position variable
  /**
   * 将整个缓冲区对象分配给attribute变量
   * 其中2指定缓冲区每个顶点的分量个数
   * gl.vertexAttrib4f,一个分配一个顶点
   * 第一个参数:顶点着色器中变量存储位置
   * 第二个参数:每个顶点的分量个数
   * 第三个参数:类型
   * 第四个参数:是否将非浮点数归一化TODO:
   * 第五个参数:
   * 第六个参数
   */
  gl.vertexAttribPointer(a_Position, 2, gl.FLOAT, false, 0, 0);
  /**
   * 激活attribute变量
   */
  gl.enableVertexAttribArray(a_Position);

  return n;
}
