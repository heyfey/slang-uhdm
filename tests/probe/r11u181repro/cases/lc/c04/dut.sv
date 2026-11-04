// § procLvIdxCallWholeSpan181 — a call as a lvalue select index in always_comb, a module function and a class method
module top(input int k);
  int arr [8];
  int y [8];
  function automatic int f(int a); return a; endfunction
  function automatic void g(int j); arr[f(j)] = 7; endfunction
  class C; int q [8]; function int h(int a); return a; endfunction function void m(int j); q[h(j)] = 1; endfunction endclass
  always_comb y[f(k)] = 1;
  initial begin C c = new; g(k); c.m(k); end
endmodule
