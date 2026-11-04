// residue (no law landed): sister ground, see README
module sub(input real r, output wire [63:0] o);
  wire [63:0] n = $realtobits(r);
  assign o = $realtobits(r);
endmodule
module top(input real r, output wire [63:0] o1, o2);
  sub u1(.r(r), .o(o1));
  sub u2(.r(r), .o(o2));
endmodule
