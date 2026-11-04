module sub #(parameter int W = 2) (input logic [2*W-1:0] i, output logic [2*W-1:0] o);
  typedef struct packed { logic [W-1:0] hi; logic [W-1:0] lo; } pair_t;
  pair_t p;
  assign p = i;
  assign o = p;
endmodule
module top(input logic [3:0] i2, input logic [15:0] i8, output logic [3:0] o2, output logic [15:0] o8);
  sub #(2) a(i2, o2);
  sub #(8) b(i8, o8);
endmodule
