// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int g (); return $urandom(); endfunction
  function bit c (int x); return $isunknown(f(x)); endfunction
endpackage
module top; bit r; initial r = p::c(1); endmodule
