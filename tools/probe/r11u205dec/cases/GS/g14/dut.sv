// r11u205 GS g14: a for-generate instance, the genvar indexing the middle of a path and the leaf a member (w.c[k].q)
package rp;
  typedef struct packed { logic q; logic r; } e_t;
  typedef struct packed { e_t [3:0] c; logic x; } r_t;
endpackage
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top(input rp::r_t w, output logic [3:0] o);
  for (genvar k = 0; k < 4; k++) begin : g
    sub u(.i(w.c[k].q), .o(o[k]));
  end
endmodule
