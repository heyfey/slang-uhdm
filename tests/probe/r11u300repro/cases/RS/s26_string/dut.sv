// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (string a); return $urandom(); endfunction
  function bit c (string s); return f(s) == 0; endfunction
  function bit d (string s); return f(s) != 0 && f(s) > 2; endfunction
endpackage
module top; bit r; initial r = p::c("x"); endmodule
