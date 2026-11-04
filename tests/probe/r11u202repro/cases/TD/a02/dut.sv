// § typeParamDefaultBoundNoReduce20
module a02 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t x;
  assign x = t'(s);
  assign o = x;
endmodule
