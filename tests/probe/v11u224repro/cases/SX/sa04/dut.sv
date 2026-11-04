// § strLitPpEscIdShift224
module top(output string o, output logic q);
  logic \my$sig ;
  initial begin \my$sig = 1; o = "a\nb` c"; q = \my$sig ; end
endmodule
