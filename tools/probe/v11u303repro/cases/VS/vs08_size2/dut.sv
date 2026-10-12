// § sysCallArgRefScopedName303
module dut (input logic [7:0] mem [4], output logic [7:0] o);
  for (genvar k = 0; k < $size(mem, 1); k++) begin : g
    assign o[k] = mem[k][0];
  end
endmodule
