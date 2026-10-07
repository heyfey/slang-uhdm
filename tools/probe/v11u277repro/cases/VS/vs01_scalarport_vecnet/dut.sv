// § strPortNetTsFromPortDecl277
module m(o);
  output o;
  wire (strong1, weak0) [3:0] o = 4'h5;
endmodule
module top(output [3:0] y);
  m u(.o(y));
endmodule
