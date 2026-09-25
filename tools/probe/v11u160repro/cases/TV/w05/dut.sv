// § tpUseBindsDefDefault160
module leaf #(parameter int W = 8, parameter type T = logic [W-1:0]) (input logic clk, input logic [2*W-1:0] d, output logic [2*W-1:0] o);
  T [1:0] q;
  always_ff @(posedge clk) q <= d;
  assign o = q;
endmodule
module top (input logic clk, input logic [7:0] d, output logic [7:0] o);
  leaf #(.W(4)) u (.clk(clk), .d(d), .o(o));
endmodule
