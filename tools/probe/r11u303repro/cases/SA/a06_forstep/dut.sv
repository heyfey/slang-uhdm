// § sysCallArgRefScopedName303
module dut #(parameter int N = 2) (input logic [7:0] i, output logic [7:0] o);
  for (genvar k = 0; k < 8; k = k + $unsigned(N)) begin : g
    assign o[k] = i[k];
  end
endmodule
