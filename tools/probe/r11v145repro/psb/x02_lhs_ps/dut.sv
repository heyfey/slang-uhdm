// § psBoundBareRefByBase145
module dut(input logic [4:0] i, output logic [31:0] a);
  localparam int W = 8;
  localparam int L = 4;
  always_comb begin
    a = '0;
    a[W:L] = i;
  end
endmodule
