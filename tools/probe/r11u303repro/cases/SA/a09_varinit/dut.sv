// § sysCallArgRefScopedName303
module dut #(parameter int N = 16) (input logic [7:0] i, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    wire [7:0] w = $unsigned(N);
    assign o[k] = w[k];
  end
endmodule
