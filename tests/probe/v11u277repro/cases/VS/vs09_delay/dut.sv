// § strPortNetTsFromPortDecl277
module m(o, r);
  output [3:0] o;
  output [1:0] r;
  wire (strong1, weak0) [3:0] #2 o = 4'd3;
  wire (weak1, strong0) [1:0] #(1, 2) r = 2'd1;
endmodule
module top(output [3:0] x, output [1:0] y);
  m u(x, y);
endmodule
