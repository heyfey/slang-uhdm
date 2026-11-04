// § progDefKeepsLastInstProcs283
program prg (input logic [3:0] a); int f; initial f = a; endprogram
module s1 (input logic [3:0] x); prg u_p (.a(x)); endmodule
module s2 (input logic [3:0] y); prg u_q (.a(y)); endmodule
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  s2 u_s2 (.y(y));
  s1 u_s1 (.x(x));
  assign o = 32'd0;
endmodule
