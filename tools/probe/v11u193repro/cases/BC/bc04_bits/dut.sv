// § connSysCallArgDefNet193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [6:0] a, output logic [7:0] o);
  logic [6:0] r;
  assign r = a;
  sub u (.d($bits(r)), .o(o));
endmodule
