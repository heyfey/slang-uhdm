// § tpUseBindsDefDefault160
module leaf #(parameter type T = logic [7:0]) (input logic clk, input T d, output T o);
  T q;
  always_ff @(posedge clk) q <= d;
  assign o = q;
endmodule
module top (input logic clk, input logic [7:0] d, output logic [7:0] o, output logic [3:0] o2);
  leaf u (.clk(clk), .d(d), .o(o));
  leaf #(.T(logic [3:0])) u2 (.clk(clk), .d(d[3:0]), .o(o2));
endmodule
