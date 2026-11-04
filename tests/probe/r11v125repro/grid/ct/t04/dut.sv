// § castTsDrainFile125
module top #(parameter int W = 3) (input logic [15:0] a, output logic [W-1:0] o, output logic [7:0] u);
  typedef struct packed { logic [3:0] h; logic [3:0] l; } pair_t;
  assign o = W'(a);
  assign u = pair_t'(a[7:0]);
endmodule
