// § doWhileSpansToCloseParen175 § doWhileEndsAtCondEnd178v
module top;
  function automatic int f(int n);
    int k = 0;
    do k += 2; while (k < n);
    return k;
  endfunction
  int r;
  initial r = f(7);
endmodule
