interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_b3_bit8 #(
  parameter bit [7:0] R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_b3_bit8 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_b3_bit8 #(.R(R)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_b3_bit8 #(.R(6)) m (clk, arr);
endmodule
