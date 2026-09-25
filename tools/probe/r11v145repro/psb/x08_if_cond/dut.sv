// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic o);
  localparam int W = 8;
  localparam int L = 4;
  always_comb begin
    if (a[W:L] == 5'd3) o = 1'b1; else o = 1'b0;
  end
endmodule
