// § connSysCallArgDefNet193
module sub (input [6:0] d, input [6:0] e, output logic [7:0] o);
  assign o = 8'(d) + 8'(e);
endmodule
module dut (input logic [6:0] a, output logic [7:0] o);
  logic [6:0] r;
  assign r = a;
  sub u (.d($unsigned(r)), .e($signed(r) + 7'sd1), .o(o));
endmodule
