// § tpCloneWholeLhsBare160
module leaf #(parameter type T = logic) (output T d_o);
  assign d_o = '0;
endmodule
module top (output logic [7:0] o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
  leaf #(.T(pair_t)) u (.d_o(o));
endmodule
