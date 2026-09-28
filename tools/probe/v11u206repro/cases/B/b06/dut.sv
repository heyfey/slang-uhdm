// § tpArrayElemBindsDefDefault206
module b06 #(parameter int W = 3, parameter type t = logic [W-1:0]) (input t i, output t o);
  logic [3:0] n;
  t m [4];
  t k [4];
  assign m[0] = i;
  assign k[1] = m[0];
  assign o = k[1];
endmodule
