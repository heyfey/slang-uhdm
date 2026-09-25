// § psBoundBareRefByBase145
module dut(input logic clk, input logic [31:0] a, output logic o);
  localparam int W = 8;
  localparam int L = 4;
  assign o = 1'b0;
  a1: assert property (@(posedge clk) a[W:L] != 5'd31);
endmodule
