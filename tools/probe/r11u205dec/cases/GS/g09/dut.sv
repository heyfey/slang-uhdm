// r11u205 GS g09: a two-level member path with a genvar index at the end (w.s.a[k])
package rp;
  typedef struct packed { logic [3:0] a; } s_t;
  typedef struct packed { s_t s; logic x; } r_t;
endpackage
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top(input rp::r_t w, output logic [3:0] o);
  for (genvar k = 0; k < 4; k++) begin : g
    sub u(.i(w.s.a[k]), .o(o[k]));
  end
endmodule
