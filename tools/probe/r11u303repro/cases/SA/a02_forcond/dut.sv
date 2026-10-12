// § sysCallArgRefScopedName303
module dut #(parameter int N = 16) (input logic [7:0] i, output logic [7:0] o);
  for (genvar k = 0; k < $clog2(N); k++) begin : g
    assign o[k] = i[k];
  end
endmodule
