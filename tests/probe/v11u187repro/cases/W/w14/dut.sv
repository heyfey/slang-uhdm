// § withClauseCloseParenEnd183 (spaces and a comment before the close paren)
module top(output int o);
  function automatic int f();
    int q[$];
    q = '{1, 5, 3};
    return q.sum() with ( item * 2  /* c */
                        );
  endfunction
  assign o = f();
endmodule
