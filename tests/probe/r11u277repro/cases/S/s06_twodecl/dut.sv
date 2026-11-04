// § strPortNetTsFromPortDecl277
module sub (o, p, r);
  output [31:0] o, p;
  output [1:0][3:0] r;
  wire (strong1, weak0) [31:0] p = 32'd5;
  wire (weak1, strong0) [1:0][3:0] r = 8'h5a;
  assign o = 32'd1;
endmodule
module dut (output logic [31:0] a, b, output logic [7:0] c);
  sub u_s (.o(a), .p(b), .r(c));
endmodule
