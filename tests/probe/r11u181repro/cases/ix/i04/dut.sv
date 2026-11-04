// § incDecBitSelWholeSpan181 — a bit-select inc/dec in a module function, a task and a class method
module top(input int i);
  int cnt [8];
  function automatic void f(int j); cnt[j]++; endfunction
  task automatic t(int j); cnt[j+1]--; endtask
  class C; int q [4]; function void g(int j); q[j]++; endfunction endclass
  initial begin C c = new; f(i); t(i); c.g(i); end
endmodule
