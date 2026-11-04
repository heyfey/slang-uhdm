// § tpArrayElemBindsDefDefault206
module e15 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input t s, output t o);
  t x [2][3];
  assign x[0][1] = s;
  assign o = x[0][1];
endmodule
