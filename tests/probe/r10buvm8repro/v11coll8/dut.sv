// NAME-COLLISION sub-law: an actual whose SPELLING equals a CALLEE FORMAL's
// name.  Surelog's evalFunc reduces each actual against a map that already
// holds the formals bound at EARLIER positions, so such an actual reduces to
// the EARLIER argument object and the later formal's typespec lands THERE.
package cp11;
  import "DPI-C" context function int dpi11(input int a, input int b);
  function int g_ab (int a, int b); return dpi11(a, b); endfunction
  function int g_ba (int b, int a); return dpi11(b, a); endfunction
  function int g_xy (int x, int y); return dpi11(x, y); endfunction
  // c1 caller formal `a`; callee (a,b); pass (a,a)   -> collision at pos1 with formal0
  function int c1 (int a);         return g_ab(a, a); endfunction
  // c2 callee (b,a); pass (a,a)                       -> no earlier collision
  function int c2 (int a);         return g_ba(a, a); endfunction
  // c3 callee (a,b); pass (b,a)                       -> pos1 actual `a` = formal0 name
  function int c3 (int a, int b);  return g_ab(b, a); endfunction
  // c4 callee (a,b); pass (a,b)                       -> same-position collisions only
  function int c4 (int a, int b);  return g_ab(a, b); endfunction
  // c5 callee (x,y); pass (a,a)                       -> no collision at all
  function int c5 (int a);         return g_xy(a, a); endfunction
  // c6 callee (a,b); pass (a,1)
  function int c6 (int a);         return g_ab(a, 1); endfunction
  // c7 callee (a,b); pass (b,b)  -> pos0 actual `b` = formal1 name (LATER, not earlier)
  function int c7 (int b);         return g_ab(b, b); endfunction
endpackage
module m11;
  int r[7];
  initial begin
    r[0]=cp11::c1(1); r[1]=cp11::c2(1); r[2]=cp11::c3(1,2); r[3]=cp11::c4(1,2);
    r[4]=cp11::c5(1); r[5]=cp11::c6(1); r[6]=cp11::c7(1);
  end
endmodule
