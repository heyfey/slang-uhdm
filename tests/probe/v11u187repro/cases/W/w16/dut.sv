// § withClauseCloseParenEnd183 (the with clause from a macro argument)
`define W(e) with (e)
module top(output int o);
  function automatic int f();
    int q[$];
    q = '{1, 5, 3};
    return q.sum() `W(item * 3);
  endfunction
  assign o = f();
endmodule
