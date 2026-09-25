// § tpCloneWholeLhsBare160
module leaf #(parameter type T = logic) (input T d_i, output T d_o, output T e_o);
  T q;
  always_comb q = d_i;
  assign d_o = q;
  assign e_o.x = q.y;
  assign e_o.y = q.x;
endmodule
module top (input logic [7:0] a, output logic [7:0] o, output logic [7:0] e);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  leaf #(.T(pair_t)) u (.d_i(a), .d_o(o), .e_o(e));
endmodule
