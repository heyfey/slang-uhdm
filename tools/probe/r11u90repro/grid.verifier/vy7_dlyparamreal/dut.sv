// v11u90 vy7 -- the delay parameter is REAL-typed.
module sub (output logic [31:0] o);
  parameter real R = 1.5;
  logic [31:0] c;
  assign #R c = 32'd10;
  assign o = c;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
