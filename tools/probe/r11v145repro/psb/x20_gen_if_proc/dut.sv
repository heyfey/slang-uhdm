// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic [4:0] o);
  localparam int W = 8;
  localparam int L = 4;
  if (1) begin : g
    always_comb o = a[W:L];
  end
endmodule
