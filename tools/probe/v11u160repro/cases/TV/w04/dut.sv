// § tpUseBindsDefDefault160
module leaf #(parameter int W = 8, parameter type T = logic [W-1:0]) (input logic clk, input T d, output T o);
  T q;
  always_ff @(posedge clk) q <= d;
  assign o = q;
endmodule
module top (input logic clk, input logic [3:0] d, output logic [3:0] o);
  leaf #(.W(4)) u (.clk(clk), .d(d), .o(o));
endmodule
