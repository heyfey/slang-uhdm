package pk;
  parameter logic [31:0] P_CAT = { 16'h0, 16'h73 };
  parameter logic [31:0] P_REP = { {25{1'b0}}, 7'h37 };
endpackage
program prg import pk::*; (input logic [31:0] x);
  initial if (x == P_CAT) $display(P_REP);
endprogram
module dut (input logic [31:0] x);
  prg pp (.x(x));
endmodule
