// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int g (); return $urandom(); endfunction
  function int c (int x); return $bits(f(x)); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
