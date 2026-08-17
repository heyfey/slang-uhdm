interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_c5_ppq #(
  parameter int R = 4, parameter int Q = 2
)(
  input logic clk,
  ifc4.host  arr[R+Q]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_c5_ppq u (clk, arr);
endmodule
