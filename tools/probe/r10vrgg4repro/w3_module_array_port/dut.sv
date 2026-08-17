interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_w3 #(parameter int R = 4)(
  input logic clk, input logic [7:0] p [R]);
endmodule
module top;
  logic clk;
  logic [7:0] sig [6];
  leaf_w3 #(.R(6)) u (clk, sig);
endmodule
