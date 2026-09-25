// § tpCloneWholeLhsBare160
module leaf #(parameter type T = logic) (input T d_i, input logic c, output T d_o);
  assign d_o = c ? d_i : '0;
endmodule
module top (input logic [7:0] a, input logic c, output logic [7:0] o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  leaf #(.T(pair_t)) u (.d_i(a), .c(c), .d_o(o));
endmodule
