// § strLitPpEscIdShift224
module top(output string o);
  initial begin
    o = "a\nb` c"; // trailing `note
  end
endmodule
