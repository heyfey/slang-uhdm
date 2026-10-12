// § sysCallArgRefScopedName303
module dut (input logic [7:0] i, output logic [7:0] o);
  typedef logic [3:0] my_t;
  for (genvar k = 0; k < $bits(my_t); k++) begin : g
    assign o[k] = i[k];
  end
endmodule
