// § withClauseCloseParenEnd183
module top(output int o);
  function automatic int f();
    int q[$];
    int r[$];
    q = '{1, 5, 3};
    r = q.find with (item > 2);
    return r.size();
  endfunction
  assign o = f();
endmodule
