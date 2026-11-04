// § ppOutputLine166
`define FF(q, d) \
  always_ff @(posedge clk) begin \
`ifdef NEVER \
    q <= '0; \
`endif \
    q <= d; \
  end
module top(input logic clk, input logic [3:0] a, output logic [3:0] y, output logic z);
  `FF(y, a) assign z = a[0];
endmodule
