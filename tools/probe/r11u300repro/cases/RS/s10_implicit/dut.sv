// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(x); endfunction
endpackage
module top (input logic a, output logic y);
  assign w = a;
  assign y = w;
  int r; initial r = p::c(1);
endmodule
