// r10buvm8 v3 — THE DPI FENCE.  v1/v2 leave ONE question open: is the callee
// fence "a DPI import" or "any resolvable callee whose constant-function fold
// FAILS"?  Every non-DPI callee measured so far FOLDED, and a folded call is
// replaced by a constant and takes its arguments out of the elaborated listing
// with it — so the two candidate laws are indistinguishable on v1/v2.
// c1..c4 give the elaborated listing a package function that CANNOT fold.
// c5..c8 close the remaining context boundaries.
package r8;
  import "DPI-C" function int dpi_i (string re, string str);
  import "DPI-C" function int dpi_j (string a);

  // c1: a callee whose body is itself a DPI call -> the fold can never succeed
  function int nofold_dpi (string a, string b); return dpi_i(a, b); endfunction
  // c2: a callee whose body reads a $system function
  function int nofold_sys (string a); return $urandom(); endfunction
  // c3: a callee whose body is a foreach over a queue
  function int nofold_q (string a);
    int q[$]; int n; n = 0;
    foreach (q[i]) n++;
    return n;
  endfunction
  // c4: a VOID-returning callee used as a statement (no return context)
  function void voidf (string a); endfunction

  function bit c1 (string s, string t);
    return (nofold_dpi(s, t) == 0);        // c1a  non-foldable SV callee
  endfunction
  function bit c2 (string s);
    return (nofold_sys(s) == 0);           // c2a
  endfunction
  function bit c3 (string s);
    return (nofold_q(s) == 0);             // c3a
  endfunction

  // c5: the function body wrapped in an EXPLICIT begin/end (paSeq_block)
  function bit c5 (string s, string t);
    begin
      return (dpi_i(s, t) == 0);           // c5a  explicit seq_block
    end
  endfunction

  // c6: DPI call nested as the argument of ANOTHER DPI call, top-level return
  function int c6 (string s, string t);
    return dpi_j(s) + dpi_i(s, t);         // c6a
  endfunction

  // c7: a DPI call inside a system function call in a top-level return
  function int c7 (string s, string t);
    return $signed(dpi_i(s, t));           // c7a
  endfunction

  // c8: a DPI call in a top-level return of a SINGLE-statement function body
  function int c8 (string s, string t);
    return dpi_i(s, t);                    // c8a  single-statement body
  endfunction

  // c9: a DPI call whose argument is a function's OUTPUT/REF formal
  function automatic int c9 (string s, ref string t);
    return dpi_i(s, t);                    // c9a  ref formal as argument
  endfunction

  // c10: the SAME DPI callee reached twice from the same top-level return
  function int c10 (string s);
    return dpi_j(s) + dpi_j(s);            // c10a
  endfunction
endpackage
