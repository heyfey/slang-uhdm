// r11u92 n2 -- the PLAIN body declaration written AFTER the strength one,
// and the strength port named SECOND in the header.
module sub (p, o);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] p = 32'd13;
  wire (strong1, weak0) [31:0] o = 32'd12;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] q;
  sub u_s (.o(o), .p(q));
endmodule
