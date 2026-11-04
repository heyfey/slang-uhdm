// § strLitPpEscIdShift224
module top(output string o);
  localparam string P = "a\nb` c";
  assign o = P;
endmodule
