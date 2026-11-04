// § tpCloneWholeLhsBare160
module leaf #(parameter type T = logic) (input T d_i, output T d_o, output logic [3:0] x);
  assign d_o = d_i;
  assign x = d_i.x;
endmodule
module top (input logic [7:0] a, output logic [7:0] o, output logic [3:0] x);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  leaf #(.T(pair_t)) u (.d_i(a), .d_o(o), .x(x));
endmodule
