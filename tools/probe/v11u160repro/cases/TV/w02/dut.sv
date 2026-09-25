// § defNetTypeParamPackedVec160
module top #(parameter type T = logic [3:0]) (input logic clk, input logic [15:0] d, output logic [15:0] o);
  T [1:0][1:0] q;
  always_ff @(posedge clk) q <= d;
  assign o = q;
endmodule
