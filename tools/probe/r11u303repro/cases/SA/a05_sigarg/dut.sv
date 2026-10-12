// § sysCallArgRefScopedName303
module dut (input logic [7:0] i, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = $countones(i) > 3;
  end
endmodule
