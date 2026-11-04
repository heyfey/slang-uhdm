// § defNetTypedefEndWrite134
`include "types.svh"
module top(input logic c, output logic o);
  s_t a [3];
  assign a[1] = {c, c, c};
  assign o = a[1].b;
endmodule
