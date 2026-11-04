// § connSysCallArgDefNet193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [7:0] a, output logic [7:0] o);
  logic [7:0] r;
  assign r = a;
  sub u (.d($signed(r[3:0])), .o(o));
endmodule
