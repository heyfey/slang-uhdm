// § tpArrayElemBindsDefDefault206
module e14 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input t s, output t o);
  wire t w [2];
  assign w[0] = s;
  assign o = w[0];
endmodule
