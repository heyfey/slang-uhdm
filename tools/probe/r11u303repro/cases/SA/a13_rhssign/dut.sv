// § sysCallArgRefScopedName303
module dut (input logic [7:0] i, output logic [7:0] o);
  localparam int MM = 3;
  for (genvar k = 0; k < 2; k++) begin : g
    logic [7:0] t;
    assign t = $unsigned(MM);
  end
  assign o = i;
endmodule
