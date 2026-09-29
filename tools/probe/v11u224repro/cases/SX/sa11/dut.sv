// § strLitPpEscIdShift224
module top(output string o, output string p);
  assign o = $sformatf("a\nb` %d", 3); assign p = "z";
endmodule
