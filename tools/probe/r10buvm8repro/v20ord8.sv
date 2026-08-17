// VERIFIER arm: DECLARATION ORDER, second layer — the callee is a DPI IMPORT
// declared AFTER the caller, an import declared BEFORE, an UNNAMED-formal
// import (evalFunc's map is keyed by the formal NAME, so "" must not collide),
// and a callee reached through a package-qualified name.
package o20;
  import "DPI-C" context function int d20a(input int a, input int b);
  import "DPI-C" context function int d20u(input int p, input int q);
  // control: import declared BEFORE this caller
  function int c_early (int a, int b); return d20a(a, b); endfunction
  // UNNAMED formals, repeated actual: the name map must not fold them together
  function int c_unnamed (int a);      return d20u(a, a); endfunction
  // the import is declared AFTER this caller (forward reference)
  function int c_late (int a, int b);  return d20late(a, b); endfunction
  import "DPI-C" context function int d20late(input int a, input int b);
  // an SV callee declared after, itself reaching a DPI import
  function int c_late2 (int a, int b); return sv_late(a, b); endfunction
  function int sv_late (int a, int b); return d20a(a, b); endfunction
endpackage
module m20;
  int r[4];
  initial begin
    r[0]=o20::c_early(1,2); r[1]=o20::c_unnamed(1);
    r[2]=o20::c_late(1,2);  r[3]=o20::c_late2(1,2);
  end
endmodule
