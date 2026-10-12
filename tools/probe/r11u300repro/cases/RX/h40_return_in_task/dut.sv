// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  task t (input int x, output int y); y = f(x); endtask
endpackage
module top; int r; initial p::t(1, r); endmodule
