// § tpArrayElemBindsDefDefault206
module b01 #(parameter int W = 3, parameter type t = logic [W-1:0]) (input t i, output t o);
  t m [2][3];
  assign m[0][0] = i;
  assign o = m[0][0];
endmodule
