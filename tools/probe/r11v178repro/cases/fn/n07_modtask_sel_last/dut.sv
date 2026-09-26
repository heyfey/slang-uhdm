// § refFullNameThroughNamedExpr175
module top;
  typedef struct { int x[4]; } s_t;
  s_t m;
  s_t ms[4];
  int r;
  task automatic t(int k); r = m.x[k] + ms[k].x[k]; endtask
  function automatic int f(int k); return m.x[k]; endfunction
  initial begin t(1); r = f(2); r = m.x[r]; end
endmodule
