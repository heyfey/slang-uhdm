// § progDefKeepsLastInstProcs283
program prg (input logic [3:0] a); int f; initial begin f = a; end endprogram
module dut (output logic [31:0] o);
  logic [3:0] x, y, z;
  prg u_1 (.a(x));
  prg u_2 (.a(y));
  prg u_3 (.a(z));
  assign o = 32'd0;
endmodule
