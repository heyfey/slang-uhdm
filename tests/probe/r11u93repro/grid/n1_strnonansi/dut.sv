// r11u92 n1 -- r11u90's u12, carried forward as the LAW B witness.
module sub (o, p);
  output [31:0] o;
  output [31:0] p;
  wire (strong1, weak0) [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] q;
  sub u_s (.o(o), .p(q));
endmodule
