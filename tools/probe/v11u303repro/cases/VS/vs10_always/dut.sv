// § sysCallArgRefScopedName303
module dut #(parameter int N = 8) (input logic [7:0] i, output logic [7:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    always_comb o[k] = $signed(i) + $clog2(N);
  end
endmodule
