// § strLitPpEscIdShift224
module top(output string o);
  initial begin
    o = "a\\\\b` c";
  end
endmodule
