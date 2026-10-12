// § sysCallArgRefScopedName303
module dut (input logic [7:0] i, output logic [7:0] o);
  localparam int MM = 3;
  if ($signed(MM) > 1) begin : g
    assign o = i;
  end
endmodule
