// r11u205 GS g07: a member select after the index (w.c[k].q) in a generate-scope instance
package rp;
  typedef struct packed { logic [1:0] q; } e_t;
  typedef struct packed { e_t [3:0] c; logic x; } r_t;
endpackage
module sub(input logic [1:0] i, output logic o);
  assign o = i[0];
endmodule
module top(input rp::r_t w, output logic [3:0] o);
  for (genvar k = 0; k < 4; k++) begin : g
    sub u(.i(w.c[k].q), .o(o[k]));
  end
endmodule
