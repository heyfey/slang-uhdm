// § strLitShiftNeedsBacktick220
module top(output string o);
  initial begin
    /* a ` b */ o = "a\\b";
  end
endmodule
