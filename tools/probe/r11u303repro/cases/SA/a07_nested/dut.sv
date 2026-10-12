// § sysCallArgRefScopedName303
module dut #(parameter int N = 16) (input logic [7:0] i, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    for (genvar j = $unsigned(k); j < 2; j++) begin : h
      assign o[2*k+j] = i[k];
    end
  end
endmodule
