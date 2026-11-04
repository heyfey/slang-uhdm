// § withCallParenSyntax286
module top;
  int q[$] = '{1, 2, 3};
  function automatic int f();
    return ((q.sum() with (item + 1)));
  endfunction
  int r;
  initial r = f();
endmodule
