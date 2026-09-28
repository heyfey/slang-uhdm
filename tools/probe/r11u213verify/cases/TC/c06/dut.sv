// § tpCastUseBindsDefDefault206
class cfg #(int N = 2);
  typedef logic [N-1:0] w_t;
endclass
module c06 #(parameter type t = cfg#(3)::w_t) (input logic s, output t o);
  t [1:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    assign x[i] = s ? t'(i + 1) : t'(0);
  end
  assign o = x[0] | x[1];
endmodule
