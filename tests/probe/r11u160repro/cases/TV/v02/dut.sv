// § defNetTypeParamPackedVec160
module child #(parameter int unsigned W = 8, parameter type addr_t = logic [W-1:0])
  (input logic clk_i, input addr_t [1:0] d_i, output addr_t [1:0] q_o);
  addr_t [1:0] q;
  assign q_o = q;
  always_ff @(posedge clk_i) q <= d_i;
endmodule
module top(input logic clk_i, input logic [15:0] d, output logic [15:0] q);
  child c (.clk_i(clk_i), .d_i(d), .q_o(q));
endmodule
