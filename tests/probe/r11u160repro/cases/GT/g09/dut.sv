// § tpCloneWholeLhsBare160
module leaf #(parameter type T = logic) (input T d_i, output logic o);
  assign o = ^d_i;
endmodule
module top (input logic [7:0] a, output logic o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  leaf #(.T(pair_t)) u (.d_i(a), .o(o));
endmodule
