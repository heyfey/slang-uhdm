// § withCallParenSyntax286
module top;
  int q[$] = '{1, 2, 3};
  int r;
  function automatic int f(int a); return a + 1; endfunction
  initial r = f((q.sum() with (item)));
endmodule
