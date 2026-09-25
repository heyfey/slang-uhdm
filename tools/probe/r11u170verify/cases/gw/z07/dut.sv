// § tpCloneWholeLhsBare160
module leaf #(parameter type T = logic) (input T d_i, output T d_o);
  T q;
  assign q = d_i;
  assign d_o = q;
endmodule
module top (input logic [7:0] a, output logic [7:0] o, output logic [7:0] o2);
  typedef struct packed { logic [1:0] x; logic [5:0] y; } pair_t;
  if (1) begin : B
    leaf #(.T(pair_t)) u (.d_i(a), .d_o(o));
  end
  leaf #(.T(pair_t)) v (.d_i(~a), .d_o(o2));
endmodule
