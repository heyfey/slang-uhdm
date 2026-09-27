// § withClauseCloseParenEnd183 (named iterator argument)
module top(output int o);
  function automatic int f();
    int q[$];
    int r[$];
    q = '{1, 5, 3};
    r = q.find(x) with (x > 2);
    return r.size();
  endfunction
  assign o = f();
endmodule
