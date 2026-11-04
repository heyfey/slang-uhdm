class inner; int v; int w; int arr[4]; endclass
class base_c; int bx; endclass
class outer extends base_c;
  int x; int y; int arr[4]; int q[$]; inner h; int n;
  function int g(int a); return a; endfunction
  function int f();
    int r;
    r = this.x;
    r = this.x + this.y;
    r = g(this.x);
    if (this.x > 0) r = 1;
    r = this.arr[this.n];
    r = this.h.v;
    r = this.h.v + 1;
    r = this.arr[1];
    r = super.bx;
    return this.y;
  endfunction
endclass
module top; outer o; initial begin o = new; end endmodule
