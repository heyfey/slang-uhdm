// § psBoundBareRefByBase145
module dut(input logic clk, input logic [3:0] d, output logic [31:0] q);
  localparam int H = 11;
  localparam int L = 8;
  always_ff @(posedge clk) q[H:L] <= d;
endmodule
