import 'dart:html';
import 'dart:math';

void main() {
  CanvasElement canvas = new CanvasElement();
  Element container = querySelector("#container");
  container.children.add(canvas);
  new SimSystem(canvas).start();  
}

Element notes = querySelector("#fps");
num fpsAverage;
/// Display the animation's FPS in a div.
void showFps(num fps) {
  if (fpsAverage == null) fpsAverage = fps;
  fpsAverage = fps * 0.05 + fpsAverage * 0.95;
  notes.text = "${fpsAverage.round()} fps";
}

class SimSystem {
  CanvasElement canvas;
  
  CanvasRenderingContext2D context;  
  num width;
  num height;
  num renderTime, dt;
  
  num x, y;
  
  SimSystem(this.canvas);
  
  void start() {
    Rectangle rect = canvas.parent.client;
    width = rect.width;
    height = rect.height;
    canvas.width = width;
    canvas.height = height;
    context = canvas.context2D;
    window.onResize.listen(resizeCanvas);
    
    x = 0;
    y = 0;
    
    redraw();
  }
  
  void resizeCanvas(e) {
    Rectangle rect = canvas.parent.client;
    width = rect.width;
    height = rect.height;
    canvas.width = width;
    canvas.height = height;
  }
  
  void update(num time) {
    if (renderTime != null) {
      dt = time - renderTime;
      showFps(1000 / dt);
      simulate();
    }
    draw();
    renderTime = time;
    redraw();
  }
  
  void redraw() {
    window.animationFrame.then(update);
  }
  
  void simulate() {
    x += dt*0.06;
    x %= width;
    y += dt*0.06;
    y %= height;
  }
  
  void draw() {
    context.clearRect(0, 0, width, height);
    context.beginPath();
    context.arc(x, y, 20, 0, PI * 2, true); 
    context.stroke();
  }
}
