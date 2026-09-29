// § strLitPpEscIdShift224
module top(input int x, output string o);
  always_comb o = $sformatf("%0d\nb` c", x);
endmodule
