class inner; int v; int w; int arr[4]; endclass
class base_c; int bx; endclass
class outer extends base_c;
  int x; int y; int arr[4]; int q[$]; inner h; int n;
  function int g(int a); return a; endfunction
  function void f();
    this.x = 1;
    this.h.v = 2;
    this.arr[1] = 3;
    this.x += 4;
    this.h.v += 5;
    this.x++;
    this.h.v++;
    --this.y;
    super.bx = 6;
  endfunction
endclass
module top; outer o; initial begin o = new; end endmodule
