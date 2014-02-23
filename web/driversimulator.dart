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
  
  num x, y, vx, vy, r;
  Random random;
  
  SimSystem(this.canvas);
  
  void start() {
    Rectangle rect = canvas.parent.client;
    width = rect.width;
    height = rect.height;
    canvas.width = width;
    canvas.height = height;
    context = canvas.context2D;
    window.onResize.listen(resizeCanvas);
    
    x = width/2;
    y = height/2;
    vx = 0;
    vy = 0;
    r = 0;
    random = new Random(new DateTime.now().millisecond);
    
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
    }
    renderTime = time;
    if (dt != null) {
      simulate();
    }
    draw();
    redraw();
  }
  
  void redraw() {
    window.animationFrame.then(update);
  }
  
  void simulate() {
    vx += (random.nextDouble()*2 - 1)*0.1;
    vy += (random.nextDouble()*2 - 1)*0.1;
    x += dt*vx*0.01;
    x %= width;
    y += dt*vy*0.01;
    y %= height;
    r = (renderTime*0.05)%30;
  }
  
  void draw() {
    context.clearRect(0, 0, width, height);
    context.beginPath();
    context.arc(x, y, r, 0, PI * 2, true); 
    context.stroke();
  }
}
