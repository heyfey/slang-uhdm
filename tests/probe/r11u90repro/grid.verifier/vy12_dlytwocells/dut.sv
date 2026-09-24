// v11u90 vy12 -- TWO delayed cells naming the SAME parameter in one module.
module sub (output logic [31:0] o);
  parameter int D = 4;
  logic [31:0] c, d;
  assign #D c = 32'd10;
  assign #D d = 32'd11;
  assign o = c ^ d;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
