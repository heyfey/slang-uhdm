// § strPortNetTsFromPortDecl277
module m(a, b, c);
  output [1:0] a;
  output signed [2:0] b;
  output [3:0] c;
  tri (strong1, weak0) [1:0] a = 2'b10;
  wor (weak1, strong0) signed [2:0] b = 3'sd1;
  wire (supply0, pull1) [3:0] c = 4'd9;
endmodule
module top(output [1:0] a, output [2:0] b, output [3:0] c);
  m u(a, b, c);
endmodule
