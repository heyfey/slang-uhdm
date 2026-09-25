// § hpSelRoute157
typedef struct packed { int W; int D; } cfg_t;
class C #(parameter cfg_t Cfg = '{W: 8, D: 3});
  bit [Cfg.W-1:0] v;
  bit [Cfg.D-1:0] s;
  function void f(int x); s = v[Cfg.D-1:0]; v = Cfg.W'(x); endfunction
endclass
module top; C #(.Cfg('{W: 12, D: 4})) o; initial begin o = new; o.f(3); end endmodule
