// r11u205 GS g13: a for-generate instance, the genvar indexing a member inside an output connection
package rp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } r_t;
endpackage
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top(input logic [3:0] i, output rp::r_t w);
  for (genvar k = 0; k < 4; k++) begin : g
    sub u(.i(i[k]), .o(w.a[k]));
  end
  assign w.b = '0;
endmodule
