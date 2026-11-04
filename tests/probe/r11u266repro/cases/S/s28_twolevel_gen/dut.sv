// § sgnLitElabFreshIntTs266
module dut (input logic [63:0] x, output logic [63:0] o);
  localparam int P = 12'shFFF;
  logic [63:0] o3 [2][2];
  for (genvar c = 0; c < 2; c++) begin : g
    for (genvar d = 0; d < 2; d++) begin : h
      assign o3[c][d] = P;
    end
  end
endmodule
