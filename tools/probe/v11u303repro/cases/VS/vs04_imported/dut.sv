// § sysCallArgRefScopedName303
package p; parameter int PN = 16; endpackage
module dut import p::*; (input logic [7:0] i, output logic [7:0] o);
  for (genvar k = 0; k < $clog2(PN); k++) begin : g
    assign o[k] = i[k];
  end
endmodule
