// § strPortNetTsFromPortDecl277
module m(.p(o), k);
  output [3:0] o;
  output [3:0] k;
  wire (strong1, weak0) [3:0] o = 4'd6;
  wire (strong1, weak0) [3:0] k = 4'd7;
endmodule
module top(output [3:0] x, output [3:0] y);
  m u(.p(x), .k(y));
endmodule
