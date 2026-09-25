// § bodyTypeParamDefaultBound160
module top (input logic clk, input logic [15:0] d, output logic [15:0] o);
  localparam type w_t = logic [7:0];
  w_t [1:0] q;
  always_ff @(posedge clk) q <= d;
  assign o = q;
endmodule
