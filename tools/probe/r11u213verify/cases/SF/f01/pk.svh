package pk;
  function automatic int f(int a, int b = 1, int c = 2, int d = 3);
    return a + b + c + d;
  endfunction
  function automatic int useit(int x);
    return f(.a(x), .d(9)) + f(.c(x), .a(0));
  endfunction
endpackage
