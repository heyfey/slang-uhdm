// § strPortNetTsFromPortDecl277
module sub (o, p);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] o = 32'd12;
  wire (strong1, weak0) [31:0] w = 32'd1;
  assign p = w;
endmodule
module dut (output logic [31:0] o, output logic [31:0] q);
  sub u_s (.o(o), .p(q));
endmodule
