// § strLitPpEscIdShift224
module top #(parameter string P = "a\nb` c") (output string o);
  assign o = P;
endmodule
