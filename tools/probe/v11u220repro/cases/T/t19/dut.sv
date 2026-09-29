// § strLitShiftNeedsBacktick220
module top(output logic [63:0] o);
  assign o = "a\\b";
endmodule
