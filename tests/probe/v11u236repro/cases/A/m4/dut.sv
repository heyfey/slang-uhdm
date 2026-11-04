// § namedCallArgFormalTs236 — distinguisher of a named call under an operation: int formals, plus a literal
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
endpackage
module top import p::*; (input int a, input int b, output int o);
  function automatic int h(file_t x, byte_t y);
    return x + y;
  endfunction
  function automatic int f(int p, int q);
    return p * q;
  endfunction
  assign o = f(.q(b), .p(a)) + 0;
endmodule
