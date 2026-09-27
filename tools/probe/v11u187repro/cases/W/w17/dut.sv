// § withClauseCloseParenEnd183 (min over a fixed array, in a condition)
module top(output int o);
  function automatic int f();
    int a[3] = '{4, 5, 6};
    int m[$];
    m = a.min() with (item - 1);
    if (m.size() > 0) return m[0];
    return 0;
  endfunction
  assign o = f();
endmodule
