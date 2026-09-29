// § strLitPpEscIdShift224
module m #(parameter string S = "") (output string o);
  assign o = S;
endmodule
module top(output string o);
  m #(.S("a\nb` c")) u(.o(o));
endmodule
