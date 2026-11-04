// § pkgRetCallFoldSharesCalleeRet300
package p;
  function logic [7:0] f (); return $urandom(); endfunction
  function bit c (int x); return f() == 0; endfunction
endpackage
module top; bit r; initial r = p::c(1); endmodule
