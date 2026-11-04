// § ppMacroBodyLines160
`define DEF_REG(q, d, rst = 1'b0) \
  always_ff @(posedge clk) begin \
    if (rst) q <= '0; \
    else q <= d; \
  end
module top (input logic clk, input logic r, input logic [3:0] d, output logic [3:0] q1, output logic [3:0] q2);
  `DEF_REG(q1, d)
  `DEF_REG(q2, ~d, r)
endmodule
