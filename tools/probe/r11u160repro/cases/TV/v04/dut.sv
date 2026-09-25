// § defNetTypeParamPackedVec160
module child #(parameter type T = logic [7:0]) (input logic clk, input logic [15:0] d, output logic [15:0] o);
  T [1:0] q;
  always_ff @(posedge clk) q <= d;
  assign o = q;
endmodule
module top(input logic clk, input logic [15:0] d, output logic [15:0] o);
  child #(.T(logic [7:0])) c (.clk(clk), .d(d), .o(o));
endmodule
