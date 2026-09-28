package pk;
  function automatic int f(int a, int b = 1, int c = 2); return a + b + c; endfunction
  function automatic int g(int x); return f(.c(x), .a(1)); endfunction
endpackage
