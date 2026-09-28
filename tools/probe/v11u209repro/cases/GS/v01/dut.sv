// § genConnTrailSelChain205: a genvar operation index at the end of a member path in a for-generate instance
package rp;
  typedef struct packed { logic [4:0] a; logic [3:0] b; } r_t;
endpackage
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top(input rp::r_t w, output logic [3:0] o);
  for (genvar k = 0; k < 4; k++) begin : g
    sub u(.i(w.a[k+1]), .o(o[k]));
  end
endmodule
