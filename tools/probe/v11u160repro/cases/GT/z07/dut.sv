// § tpCloneWholeLhsBare160
module leaf #(parameter type T = logic) (input T d_i, output T d_o);
  assign d_o = d_i;
endmodule
module mid #(parameter type U = logic) (input U a, output U b);
  leaf #(.T(U)) l (.d_i(a), .d_o(b));
endmodule
module top (input logic [7:0] a, output logic [7:0] o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  mid #(.U(pair_t)) u (.a(a), .b(o));
endmodule
