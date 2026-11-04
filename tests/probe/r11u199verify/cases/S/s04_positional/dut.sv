// § connSysCallArgDefNet193
module sub (input [6:0] d, input [6:0] e, output logic [7:0] o);
  assign o = 8'(d) + 8'(e);
endmodule
module dut (input logic [6:0] i, output logic [7:0] o);
  logic [6:0] r;
  assign r = i;
  sub u ($unsigned(r), $signed(r[5:0]), o);
endmodule
