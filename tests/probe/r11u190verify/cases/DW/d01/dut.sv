// § doWhileMacroCondEnd181 (r11u190: a macro condition followed by a trailing comment, and a macro condition inside written parentheses)
`define C (i < 5) // the limit
`define LIM 5
module top;
  int i, j;
  initial begin
    do j++; while `C; // tail comment
    do begin i++; end while (i < `LIM); /* block */
    do i--; while (`C);
  end
endmodule
