// § defNetTypeParamPackedVec160
module top #(parameter type T = logic) (input logic clk, input logic [3:0] d, output logic [3:0] o);
  T [3:0] q;
  always_ff @(posedge clk) q <= d;
  assign o = q;
endmodule
