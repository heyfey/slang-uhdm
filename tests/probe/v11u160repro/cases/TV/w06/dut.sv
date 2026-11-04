// § tpUseBindsDefDefault160
module leaf #(parameter type T = logic [7:0]) (input logic clk, input T d, output T o);
  T q;
  always_ff @(posedge clk) q <= d;
  assign o = q;
endmodule
module top (input logic clk, input logic [7:0] d, output logic [7:0] o);
  leaf #(logic [7:0]) u (.clk(clk), .d(d), .o(o));
endmodule
