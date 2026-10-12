// § sysCallArgRefScopedName303
module dut (input logic [7:0] i, output logic [7:0] o);
  if ($bits(i) == 8) begin : g
    assign o = i;
  end
endmodule
