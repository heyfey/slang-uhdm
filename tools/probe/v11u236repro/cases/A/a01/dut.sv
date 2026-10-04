// § namedCallArgFormalTs236 — named-argument calls in always_comb and initial processes of a module
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
endpackage
module top import p::*; (input int a, input int b, output int o, output int o2);
  function automatic int h(file_t x, byte_t y);
    return x + y;
  endfunction
  int r;
  always_comb o = h(.y(b), .x(a));
  initial r = h(.x(3), .y(b));
  assign o2 = r;
endmodule
