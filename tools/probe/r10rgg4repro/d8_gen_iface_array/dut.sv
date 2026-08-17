interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_d8 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
endmodule
module mid_d8 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  generate if (1) begin : g
    leaf_d8 #(.R(R)) u (clk, arr);
  end endgenerate
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_d8 #(.R(6)) m (clk, arr);
endmodule
