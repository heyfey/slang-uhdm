// § progDefKeepsLastInstProcs283
program prg (input logic [3:0] a, output logic [3:0] b); assign b = a; int f; initial f = a; endprogram
module dut (output logic [31:0] o);
  logic [3:0] x, y, p, q;
  prg u_1 (.a(x), .b(p));
  prg u_2 (.a(y), .b(q));
  assign o = 32'd0;
endmodule
