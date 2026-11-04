// § sysCallArgRefScopedName303
module dut #(parameter int unsigned NC = 6) (input logic [7:0] i, output logic [7:0] o);
  localparam int unsigned MM = 3;
  for (genvar k = 0; k < $unsigned(MM); k++) begin : g
    assign o[k] = i[k];
  end
endmodule
