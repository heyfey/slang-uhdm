// § withClauseCloseParenEnd183 (the call written in a macro body)
`define S(a) a.sum() with (item * 2)
module top(output int o);
  function automatic int f();
    int q[$];
    q = '{1, 5, 3};
    return `S(q);
  endfunction
  assign o = f();
endmodule
