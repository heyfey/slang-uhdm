// § strPortNetTsFromPortDecl277
module m(io, i);
  inout [3:0] io;
  input [1:0] i;
  wire (pull1, pull0) [3:0] io = {2'b00, i};
endmodule
module top(inout [3:0] io, input [1:0] i);
  m u(io, i);
endmodule
