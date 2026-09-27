// § doWhileSyntaxFromCond181 — controls: a declared local in a plain class method, a module task and a package function
package p;
  class D;
    int n;
    task t(); do begin int y; y = n; n = n - y; end while (n > 0); endtask
  endclass
  function automatic int f(int n); do begin int z; z = 1; n = n - z; end while (n > 0); return n; endfunction
endpackage
module top;
  int m;
  task automatic u(); do begin int w; w = 2; m = m - w; end while (m > 0); endtask
endmodule
