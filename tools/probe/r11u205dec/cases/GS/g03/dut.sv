// r11u205 GS g03: an indexed part select of a member (genvar base) in a generate-scope instance
package rp;
  typedef struct packed { logic [7:0] a; logic [3:0] b; } r_t;
endpackage
module sub(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
module top(input rp::r_t w, output logic [7:0] o);
  for (genvar k = 0; k < 4; k++) begin : g
    sub u(.i(w.a[2*k+:2]), .o(o[2*k+:2]));
  end
endmodule
