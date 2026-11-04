// § procLvIdxCallWholeSpan181 — a call as a lvalue select index in a package function and a module task
package p;
  function automatic int f(int a); return a; endfunction
  function automatic int g(int j); int arr [8]; arr[f(j)] = 1; return arr[0]; endfunction
endpackage
module top;
  int arr [8];
  int k, r;
  task automatic t(int j); arr[p::f(j)] = 2; endtask
  initial begin t(k); r = p::g(k); end
endmodule
