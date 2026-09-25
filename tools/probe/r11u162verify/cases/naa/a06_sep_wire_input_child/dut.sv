// § naArrNetOwnPortDecl155v
module sub(a, o);
  input a;
  output [3:0] o;
  wire [3:0] a [2];
  assign o = a[0] ^ a[1];
endmodule
module top(input wire [3:0] a [2], output wire [3:0] o); sub u (a, o); endmodule
