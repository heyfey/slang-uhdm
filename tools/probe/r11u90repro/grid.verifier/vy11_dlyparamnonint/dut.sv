// v11u90 vy11 -- the delay names a GENVAR-like non-parameter: a plain
// variable declared in the module body.
module sub (output logic [31:0] o);
  logic [31:0] dv = 32'd3;
  logic [31:0] c;
  assign #dv c = 32'd10;
  assign o = c;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
