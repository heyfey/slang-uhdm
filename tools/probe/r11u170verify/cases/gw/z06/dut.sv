// § tpCloneWholeLhsBare160
module leaf #(parameter type T = logic) (input T d_i, output T d_o);
  assign d_o = d_i;
endmodule
module mid #(parameter type T = logic) (input T d_i, output T d_o);
  leaf #(.T(T)) l(.d_i(d_i), .d_o(d_o));
endmodule
module top (input logic [7:0] a, output logic [7:0] o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  mid #(.T(pair_t)) m(.d_i(a), .d_o(o));
endmodule
