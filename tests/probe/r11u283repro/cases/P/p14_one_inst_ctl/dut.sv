// § progDefKeepsLastInstProcs283
program prg (input logic [3:0] a); int f; initial f = a; endprogram
module dut (output logic [31:0] o);
  logic [3:0] x;
  prg u_1 (.a(x));
  assign o = 32'd0;
endmodule
