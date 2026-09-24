// v11u90 vy8 -- the SAME parameter name D at two nesting levels.
module inner (output logic [31:0] o);
  parameter int D = 2;
  logic [31:0] c;
  assign #D c = 32'd10;
  assign o = c;
endmodule
module sub (output logic [31:0] o);
  parameter int D = 8;
  logic [31:0] c;
  assign #D c = 32'd20;
  logic [31:0] q;
  inner u_i (.o(q));
  assign o = c ^ q;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
