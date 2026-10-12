// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (); return $urandom; endfunction
  function int c (int x); return f() == 0; endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
