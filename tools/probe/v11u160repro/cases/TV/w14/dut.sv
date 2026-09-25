// § tpUseBindsDefDefault160
module leaf #(parameter type T = logic [7:0]) (input logic clk, input T d, output T o);
  T q;
  always_ff @(posedge clk) q <= d;
  assign o = q;
endmodule
module mid #(parameter int K = 1) (input logic clk, input logic [7:0] d, output logic [7:0] o);
  leaf u (.clk(clk), .d(d), .o(o));
endmodule
module top (input logic clk, input logic [7:0] d, output logic [7:0] o, output logic [7:0] o2);
  mid #(.K(2)) m1 (.clk(clk), .d(d), .o(o));
  mid m2 (.clk(clk), .d(d), .o(o2));
endmodule
