// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function automatic int c (int x);
    int acc;
    begin : nb
      int k;
      k = x;
      acc = f(k);
    end
    return f(acc);
  endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
