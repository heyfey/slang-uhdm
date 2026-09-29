// § strLitShiftNeedsBacktick220 — backslash string literals as a parameter value, a $sformatf argument and a concatenation operand, with and without a backtick-space
module top(output string o1, output string o2, output string o3);
  parameter string PS = "path\\to\\x";
  localparam string LB = "t\\ ` u";
  initial begin
    o1 = $sformatf("%s\\n", PS);
    o2 = {"ab\\", LB};
    o3 = {LB, "c\\d"};
  end
endmodule
