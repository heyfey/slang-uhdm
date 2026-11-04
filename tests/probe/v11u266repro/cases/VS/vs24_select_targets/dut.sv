// § sgnLitElabFreshIntTs266
module dut (output logic [63:0] o);
  localparam int P = 8'sh05;
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k*32 +: 32] = P;
  end
endmodule
