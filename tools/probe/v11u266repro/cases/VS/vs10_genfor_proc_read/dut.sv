// § sgnLitElabFreshIntTs266
module dut (output logic [31:0] o [2]);
  localparam int P = 6'so17;
  for (genvar k = 0; k < 2; k++) begin : g
    always_comb o[k] = P + k;
  end
endmodule
