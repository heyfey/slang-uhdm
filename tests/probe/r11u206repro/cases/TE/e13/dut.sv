// § tpArrayElemBindsDefDefault206
module e13 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input t s, output t o);
  t x [4];
  assign x[0] = s;
  assign o = x[0];
endmodule
