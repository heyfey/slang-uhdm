// § sysCallArgRefScopedName303
module dut (input logic [7:0] i, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    localparam int LP = 4 + k;
    for (genvar j = 0; j < $clog2(LP); j++) begin : h
      assign o[k*4+j] = i[j];
    end
  end
endmodule
