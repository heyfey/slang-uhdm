// § doWhileMacroCondEnd181 — controls: the whole do-while in a macro, and a condition macro inside a class method and a function
`define DW(v) do v = v + 1; while (v < 3);
`define C (n > 0)
module top;
  int i;
  initial begin `DW(i) end
  function automatic int f(int n); do n--; while `C; return n; endfunction
  class K; int n; task t(); do n--; while `C; endtask endclass
endmodule
