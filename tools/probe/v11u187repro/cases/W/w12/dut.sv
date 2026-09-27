// § withClauseCloseParenEnd183 (method without parentheses)
module top(output int o);
  function automatic int f();
    int q[$];
    q = '{1, 5, 3};
    return q.sum with (item + 1);
  endfunction
  assign o = f();
endmodule
