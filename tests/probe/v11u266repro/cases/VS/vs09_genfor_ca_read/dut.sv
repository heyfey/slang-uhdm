// § sgnLitElabFreshIntTs266
module dut (output logic [31:0] o [2]);
  parameter int signed P = 32'sd5;
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = P;
  end
endmodule
