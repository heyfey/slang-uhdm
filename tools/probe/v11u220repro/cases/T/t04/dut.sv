// § strLitShiftNeedsBacktick220
module top(output string o, output string q);
  initial begin
    q = "c` d"; o = "a\\b";
  end
endmodule
