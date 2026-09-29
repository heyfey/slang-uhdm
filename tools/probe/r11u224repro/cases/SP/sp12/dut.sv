// § strLitPpEscIdShift224
module top(input string s, output logic o);
  always_comb begin
    if (s == "a\nb` c") o = 1; else o = 0;
  end
endmodule
