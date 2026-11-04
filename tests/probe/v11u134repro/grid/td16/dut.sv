// § defNetTypedefEndWrite134
`include "pkg.svh"
module top(input logic c, output logic o);
  import p::*;
  s_t a [3];
  s_t b;
  assign a[1] = {c, c, c};
  assign b = a[1];
  assign o = b.b;
endmodule
