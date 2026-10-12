// § sysCallArgRefScopedName303
module dut #(parameter int N = 8) (output logic [7:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = $clog2(N);
  end
endmodule
