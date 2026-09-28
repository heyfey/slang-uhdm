// § genConnTrailSelChain205: two trailing selects on a member of an unpacked array member in a for-generate
package rp;
  typedef struct packed { logic [1:0][3:0] m; logic z; } r_t;
endpackage
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top(input rp::r_t w, output logic [1:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    sub u(.i(w.m[k][0]), .o(o[k]));
  end
endmodule
