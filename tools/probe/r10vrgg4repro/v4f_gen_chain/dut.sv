interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v4f #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  if (1) begin : g
    leaf_a #(.R(R)) u (clk, arr);
  end
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v4f #(.R(6)) m (clk, arr);
endmodule
