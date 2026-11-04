// § typeParamDefaultBoundNoReduce20
module a04 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t x [4];
  assign x[0] = t'(s);
  assign o = x[0];
endmodule
