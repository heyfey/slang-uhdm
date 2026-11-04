// § doWhileMacroCondEnd181 — break hunt: a condition macro defined in an included file, a condition macro over two lines, a nested do-while
`include "a07_inc.svh"
`define C2(a) (a \
  > 0)
module top;
  int i, j;
  initial begin
    do i++; while `CI;
    do j--; while `C2(j);
    do begin do i--; while `CI; end while (i > 100);
  end
endmodule
