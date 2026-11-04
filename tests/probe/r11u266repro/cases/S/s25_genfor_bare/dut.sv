// § sgnLitElabFreshIntTs266
module dut (input logic [63:0] x, output logic [63:0] o);
  localparam int P = 12'shFFF;
  logic [63:0] o3 [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o3[c] = P;
  end
endmodule
