// § strPortNetTsFromPortDecl277
module m #(parameter W = 4) (o);
  output [W-1:0] o;
  wire (pull1, strong0) [W-1:0] o = {W{1'b1}};
endmodule
module top(output [3:0] a, output [7:0] b);
  m #(4) u1(.o(a));
  m #(.W(8)) u2(.o(b));
endmodule
