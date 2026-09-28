// r11u205 GS g11: a module-scope instance (no generate) with a parameter-indexed member select
package rp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } r_t;
endpackage
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top #(parameter int K = 1) (input rp::r_t w, output logic o);
  sub u(.i(w.a[K]), .o(o));
endmodule
