// § tpArrayElemBindsDefDefault206
module b07 #(parameter int W = 3, parameter type t = logic signed [W-1:0]) (input t i, output t o);
  var t m [2:0];
  assign m[2] = i;
  assign o = m[2];
endmodule
