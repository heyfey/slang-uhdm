// § sysCallArgRefScopedName303
module dut (input logic [7:0] i, output logic [3:0] o [4]);
  for (genvar k = 1; k < 5; k++) begin : g
    assign o[k-1] = $clog2(k);
  end
endmodule
