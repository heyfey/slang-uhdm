// § strLitContOwnerEnd224
module top(input logic c, output string o);
  assign o = c ? "ab \
cd" : "x";
endmodule
