class inner; int v; int w; int arr[4]; endclass
class base_c; int bx; endclass
class outer extends base_c;
  int x; int y; int arr[4]; int q[$]; inner h; int n;
  function int g(int a); return a; endfunction
  function void f();
    this.x = this.y;
    this.h.v = this.h.w;
    this.arr[this.n] = this.x;
    this.q.push_back(this.x);
    $display("%0d", this.h.v);
  endfunction
endclass
module top; outer o; initial begin o = new; end endmodule
