// r11u205 GS g06: positional connection of a genvar-indexed member select
package rp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } r_t;
endpackage
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top(input rp::r_t w, output logic [3:0] o);
  for (genvar k = 0; k < 4; k++) begin : g
    sub u(w.a[k], o[k]);
  end
endmodule
