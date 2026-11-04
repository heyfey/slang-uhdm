// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic [4:0] o [2]);
  localparam int W = 8;
  localparam int L = 4;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = a[W:L];
  end
endmodule
