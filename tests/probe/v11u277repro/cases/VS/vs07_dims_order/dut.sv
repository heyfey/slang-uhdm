// § strPortNetTsFromPortDecl277
module m(o, p);
  wire (strong1, weak0) [0:3] o = 4'b1010;
  output [0:3] o;
  output [7:4] p;
  wire (strong1, weak0) [7:4] p = 4'hc;
endmodule
module top(output [3:0] x, output [3:0] y);
  m u(x, y);
endmodule
