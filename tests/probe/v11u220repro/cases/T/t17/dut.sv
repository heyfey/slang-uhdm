// § strLitShiftNeedsBacktick220
module top(output logic [63:0] o);
  always_comb o = "a\nb";
endmodule
