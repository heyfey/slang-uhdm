// § strPortNetTsFromPortDecl277
module m(o, s, t);
  output [3:0] o;
  output signed s;
  output [2:0] t;
  trireg (small) [3:0] o;
  wire (strong1, weak0) signed [3:0] s = 4'sd3;
  trireg (large) [2:0] t;
  assign t = 3'd1;
endmodule
module top(output [3:0] x, output y, output [2:0] z);
  m u(x, y, z);
endmodule
