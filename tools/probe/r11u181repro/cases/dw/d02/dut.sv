// § doWhileMacroCondEnd181 — a function-like macro condition and a macro-born operand inside written parentheses
`define LT(a, b) (a < b)
`define N 3
module top;
  int j, k;
  initial begin
    do j++; while `LT(j, 3);
    do k++; while (k < `N);
  end
endmodule
