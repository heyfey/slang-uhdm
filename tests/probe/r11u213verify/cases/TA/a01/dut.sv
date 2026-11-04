// § tpArrayElemBindsDefDefault206
module a01 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input t i, output t o);
  t m [2][2][2];
  assign m[1][0][1] = i;
  assign o = m[1][0][1];
endmodule
