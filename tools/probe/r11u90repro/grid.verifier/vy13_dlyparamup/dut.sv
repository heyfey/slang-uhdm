// v11u90 vy13 -- the delay names a parameter of an OUTER module (upward
// name resolution), not one of the holder's own members.
module sub (output logic [31:0] o);
  logic [31:0] c;
  assign #TOPD c = 32'd10;
  assign o = c;
endmodule
module dut (output logic [31:0] o);
  parameter int TOPD = 5;
  sub u_s (.o(o));
endmodule
