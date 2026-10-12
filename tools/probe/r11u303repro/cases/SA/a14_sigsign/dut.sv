// § sysCallArgRefScopedName303
module dut (input logic [7:0] i, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    logic [7:0] t;
    assign t = $unsigned(i);
  end
  assign o = i;
endmodule
