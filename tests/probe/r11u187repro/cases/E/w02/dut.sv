// § withClauseCloseParenEnd183
module top(output int o);
  function automatic int f();
    int q[$];
    q = '{1, 5, 3};
    return q.sum() with ( int'(item) * 2 );
  endfunction
  assign o = f();
endmodule
