// § namedCallArgCtx236v — distinguisher of a named call under an operation: int formals, the call as the right operand
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
  assign o = a + f(.q(b), .p(a));
endmodule
