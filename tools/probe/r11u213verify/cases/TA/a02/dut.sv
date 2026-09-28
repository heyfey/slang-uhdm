// § tpArrayElemBindsDefDefault206
module a02 #(parameter int W = 3, parameter type t = logic [W-1:0]) (input t i, output t o);
  tri t n [3];
  wand t w [2];
  assign n[0] = i;
  assign w[1] = n[0];
  assign o = w[1];
endmodule
