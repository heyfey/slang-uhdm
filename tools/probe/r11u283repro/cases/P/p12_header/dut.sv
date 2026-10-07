// § progDefKeepsLastInstProcs283
`include "prg.svh"
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  prg u_1 (.a(x));
  prg u_2 (.a(y));
  assign o = 32'd0;
endmodule
