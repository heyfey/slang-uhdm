// § tfArgClassMethodOrder176
package p;
  typedef struct { int a; int b; } s_t;
  class k;
    function int f(s_t x);
      return x.a;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  k o; s_t v; int r;
  initial begin o = new; r = o.f(v); end
endmodule
