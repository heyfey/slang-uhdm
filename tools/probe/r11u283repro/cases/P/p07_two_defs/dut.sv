// § progDefKeepsLastInstProcs283
program pa (input logic [3:0] a); int f; initial f = a; endprogram
program pb (input logic [3:0] b); int g; initial g = b; endprogram
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  pa u_a1 (.a(x));
  pb u_b1 (.b(x));
  pa u_a2 (.a(y));
  pb u_b2 (.b(y));
  assign o = 32'd0;
endmodule
