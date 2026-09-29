// § strLitContOwnerEnd224
module top(input logic c, output string o);
  string q = c ? "x" : "ab \
cd";
  assign o = q;
endmodule
