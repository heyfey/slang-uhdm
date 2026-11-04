// § progDefKeepsLastInstProcs283
program prg (input logic [3:0] a, input logic [3:0] b); int f; initial f = a + b; endprogram
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  prg u_1 (x, y);
  prg u_2 (y, x);
  assign o = 32'd0;
endmodule
