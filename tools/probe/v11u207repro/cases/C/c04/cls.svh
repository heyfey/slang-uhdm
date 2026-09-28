class K;
  function int f(int a, int b = 1, int c = 2); return a + b + c; endfunction
  function int g(); return f(.c(3), .a(1)); endfunction
endclass
