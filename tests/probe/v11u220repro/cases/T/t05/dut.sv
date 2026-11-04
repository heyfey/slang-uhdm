// § strLitShiftNeedsBacktick220
module top(output string o, output string q);
  initial begin
    o = "a\\b"; q = "c` d";
  end
endmodule
