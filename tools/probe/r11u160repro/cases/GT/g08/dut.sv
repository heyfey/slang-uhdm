// § tpCloneWholeLhsBare160
module leaf #(parameter type T = logic) (input T d_i, output logic o);
  assign o = ^d_i;
endmodule
module top (output logic o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  pair_t a;
  assign a = '0;
  leaf #(.T(pair_t)) u (.d_i(a), .o(o));
endmodule
