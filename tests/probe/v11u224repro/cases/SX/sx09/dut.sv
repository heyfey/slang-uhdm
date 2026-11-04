// § strLitPpEscIdShift224
module top(output string o);
  initial begin
    o = "a\x41b` c";
  end
endmodule
