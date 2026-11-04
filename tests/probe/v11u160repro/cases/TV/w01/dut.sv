// § defNetTypeParamPackedVec160
module top #(parameter type T = logic signed [3:0]) (input logic clk, input logic [7:0] d, output logic [7:0] o);
  T [1:0] q;
  always_ff @(posedge clk) q <= d;
  assign o = q;
endmodule
