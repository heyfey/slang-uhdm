// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (); return $urandom(); endfunction
  function int c (int x); return f() + f(); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
