// § sgnLitElabFreshIntTs266
module leaf #(parameter int P = 8'sd7) (output logic [31:0] o [2][2], output logic [31:0] q [2]);
  for (genvar k = 0; k < 2; k++) begin : a
    for (genvar j = 0; j < 2; j++) begin : b
      assign o[k][j] = P + j;
    end
    always_comb q[k] = P - k;
  end
endmodule
module dut (output logic [31:0] o [2][2], output logic [31:0] q [2]);
  for (genvar m = 0; m < 1; m++) begin : g
    leaf u (.o(o), .q(q));
  end
endmodule
