// § strLitContOwnerEnd224
module top(input logic c, output string o);
  assign o = c ? "x" : "ab \
cd";
endmodule
