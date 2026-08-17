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
module mid_c5_ppq #(parameter int R = 4, parameter int Q = 2)(input logic clk, ifc4.host arr[R+Q]);
  leaf_c5_ppq #(.R(R), .Q(Q)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[8]();
  mid_c5_ppq #(.R(6)) m (clk, arr);
endmodule
