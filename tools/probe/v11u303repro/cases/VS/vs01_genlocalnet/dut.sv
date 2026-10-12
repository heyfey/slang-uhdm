// § sysCallArgRefScopedName303
module dut (input logic [7:0] i, output logic [3:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    wire [7:0] w = i;
    assign o[k] = $countones(w);
  end
endmodule
