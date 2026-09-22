// r11u92 n8 -- TWO strength-decorated non-ANSI port declarations, and a plain
// body net between them.
module sub (o, p, r);
  output [31:0] o;
  output [31:0] p;
  output [31:0] r;
  wire (strong1, weak0) [31:0] o = 32'd12;
  wire [31:0] mid = 32'd14;
  wire (supply1, supply0) [31:0] p = 32'd13;
  wire [31:0] r = 32'd15;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] q, t;
  sub u_s (.o(o), .p(q), .r(t));
endmodule
