// § namedSlotFillerRootFile207: a named call written by a macro defined in an included header, and a task call with a skipped middle formal written the same way
`include "mac.svh"
module top(output int o);
  function automatic int f(int a = 0, int b = 1, int c = 2); return a + b + c; endfunction
  task automatic t(int a, int b = 1, output int c); c = a + b; endtask
  int r;
  initial begin
    o = `CALLF(5);
    t(.a(1), .c(r));
    `CALLT(2);
  end
endmodule
