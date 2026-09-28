// r11u205 GS g12: a for-generate instance, a parameter (not the genvar) indexing a member
package rp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } r_t;
endpackage
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top #(parameter int K = 1) (input rp::r_t w, output logic [1:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    sub u(.i(w.a[K]), .o(o[k]));
  end
endmodule
