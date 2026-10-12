// § sysCallArgRefScopedName303
module dut (input logic [7:0] i, output logic [7:0] o);
  localparam int MM = 1;
  for (genvar k = $signed(MM); k < 3; k++) begin : g
    assign o[k] = i[k];
  end
  assign o[0] = i[0];
endmodule
