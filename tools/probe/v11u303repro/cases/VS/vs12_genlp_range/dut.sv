// § sysCallArgRefScopedName303
module dut #(parameter int N = 8) (output logic [7:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    logic [$clog2(N)-1:0] q;
    assign o[k] = q;
  end
endmodule
