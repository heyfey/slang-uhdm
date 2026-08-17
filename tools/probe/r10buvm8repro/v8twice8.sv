// ONE cell: the SAME ref used at TWO argument positions of one call in the
// § pkgRetTopCallArgFormalTs8 window.
package tp8;
  import "DPI-C" context function int dpi8(input int a, input int b);
  function int f2 (int a, int b); return dpi8(a, b); endfunction
  function int t_same (int a);  return f2(a, a); endfunction
endpackage
module m8;
  int r;
  initial r = tp8::t_same(1);
endmodule
