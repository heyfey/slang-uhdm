// § namedCallArgFormalTs236 — a named call driving an implicit net (a09 alone)
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
endpackage
module top import p::*; (input int a, input int b, output int o);
  function automatic int h(file_t x, byte_t y);
    return x + y;
  endfunction
  assign w = h(.y(b), .x(a));
  assign o = w;
endmodule
