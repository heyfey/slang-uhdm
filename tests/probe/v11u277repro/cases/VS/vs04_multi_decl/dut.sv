// § strPortNetTsFromPortDecl277
module m(o1, o2, q);
  output [3:0] o1, o2;
  output [1:0] q;
  wire (strong1, weak0) [3:0] o1 = 4'd1, o2 = 4'd2;
  wire [1:0] q;
  assign q = 2'd3;
endmodule
module top(output [3:0] x, output [3:0] y, output [1:0] z);
  m u(.o1(x), .o2(y), .q(z));
endmodule
