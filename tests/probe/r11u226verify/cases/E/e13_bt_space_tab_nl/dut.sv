// § strLitShiftNeedsBacktick220 — string literals with a backtick then a space, a backtick then an escaped newline, escaped quotes beside a backslash, and no backtick with several backslashes
module top(output string o1, output string o2, output string o3, output string o4);
  initial begin
    o1 = "a\\b` c";
    o2 = "q\"r\\s\"";
    o3 = "p\\\\q\\r";
    o4 = "x`\ny";
  end
endmodule
