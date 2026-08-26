// r10v151 (VERIFIER) arm 9 — SPACING AND SUBSCRIPT SHAPES.  A subscript that is
// a CALL, a SPACED subscript, a SPACED method dot, and a SPACED receiver dot —
// every one of them a place a TEXT-derived base name could go wrong.
// (`q.map() with (…)` is slang's OTHER WithClauseMode::Iterator face,
// ArrayMethods.cpp:968, but it is 1800-2023-only and slang refuses it at the
// campaign's default std, so it is unreachable and is not scored here.)
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.
package Mpk9;
  function automatic int pick9(int s9); return s9; endfunction
  class Grid9;
    int lane9[$];
    int mesh9[4][$];
    task walk9;
      int t9;
      t9 = 0;
      mesh9[pick9(1)].sort() with ( item );   // subscript is a CALL
      mesh9 [3].sort() with ( item );         // SPACED subscript
      mesh9[3] .rsort() with ( item );        // SPACED dot
      lane9 . sort() with ( item );           // SPACED receiver dot
      lane9.  unique();                       // SPACED keyword method
      mesh9[t9 + pick9(0)].and();             // KEYWORD, compound subscript
    endtask
  endclass
endpackage
