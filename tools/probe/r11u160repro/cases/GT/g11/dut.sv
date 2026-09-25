// § tpCloneWholeLhsBare160
module leaf #(parameter type T = logic) (input T d_i, output T d_o);
  assign d_o = d_i;
endmodule
module top (output logic [7:0] o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  pair_t a;
  assign a = '0;
  leaf #(.T(pair_t)) u (.d_i(a), .d_o(o));
endmodule
