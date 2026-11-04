// § defNetTypeParamPackedVec160
module top #(parameter type T = logic [7:0]) (input logic clk, input logic [15:0] d, output logic [15:0] o);
  T [1:0] q, r;
  always_ff @(posedge clk) begin q <= d; r <= q; end
  assign o = r;
endmodule
