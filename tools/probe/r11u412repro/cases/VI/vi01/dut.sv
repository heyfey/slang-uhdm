// § elabVarSysCallInit412
module cpu;
  logic [7:0] raddr = $random();
  logic [7:0] r2 = 8'd5;
  int r3 = $urandom;
  logic [7:0] r4 = $random;
endmodule
module top;
  cpu c();
endmodule
