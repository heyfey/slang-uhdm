// § strLitPpEscIdShift224
module top(output string o);
  initial begin
    o = "a\nb `FOO c";
  end
endmodule
