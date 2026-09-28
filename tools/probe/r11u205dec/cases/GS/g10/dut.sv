// r11u205 GS g10: an if-generate instance with a parameter-indexed member select
package rp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } r_t;
endpackage
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top #(parameter int K = 1) (input rp::r_t w, output logic o);
  if (K == 1) begin : g
    sub u(.i(w.a[K]), .o(o));
  end
endmodule
