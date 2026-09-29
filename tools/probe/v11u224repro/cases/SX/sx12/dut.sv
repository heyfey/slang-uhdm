// § strLitPpEscIdShift224
module top(input logic c, output string o);
  assign o = c ? "a\nb` c" : "d\ne` f";
endmodule
