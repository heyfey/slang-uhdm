// § progDefKeepsLastInstProcs283
program prg (a, f);
  input logic [3:0] a;
  output int f = 5;
  initial f = a;
endprogram
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  int r1, r2;
  prg u_1 (.a(x), .f(r1));
  prg u_2 (.a(y), .f(r2));
  assign o = 32'd0;
endmodule
