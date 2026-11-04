// § cloneOwnCopyInstHomeTop482 (struct local, the typedef also used in a module port)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t s;
    s.data = n;
    return s.data;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module sub(input u::op_t p, output int o);
  assign o = p.data;
endmodule
module top;
  import a::*;
  u::op_t w;
  int x, y;
  sub s0(.p(w), .o(y));
  initial x = g();
endmodule
