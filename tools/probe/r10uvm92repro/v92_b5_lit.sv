// r10uvm92 VERIFIER arm b5 — literal spellings, case, separators, strings.
package lz;
  class node; int w; endclass
  class jar;
    node slot[];
    node smap[string];
  endclass

  class probe;
    jar  jj;
    int  n;
    string sx;
    function void lits();
      // l01..l06 base characters, upper and lower, with and without size
      jj.slot[n + 8'hab]  = null;
      jj.slot[n + 8'HAB]  = null;
      jj.slot[n + 8'B1010_1010] = null;
      jj.slot[n + 'D99]   = null;
      jj.slot[n + 12'O777] = null;
      jj.slot[n + 6'sB11]  = null;
      // l07..l09 separators and internal blanks
      jj.slot[n + 32'h DEAD_beef] = null;
      jj.slot[n + 1_000]  = null;
      jj.slot[n + 16'b0000_1111_0000_1111] = null;
      // l10..l12 x/z and unbased
      jj.slot[n + 4'bxz01] = null;
      jj.slot[n + 4'dX]    = null;
      jj.slot[n + 'z]      = null;
      // l13 string operands in a STRING concat index (assoc array)
      jj.smap[{sx, "a_b"}]  = null;
      jj.smap[{"c d", sx}]  = null;
      jj.smap[{sx, "q", "r"}] = null;
      // l14 implication / equivalence
      jj.slot[n -> 1]  = null;
      // l15 case-eq family
      jj.slot[n === 1] = null;
      jj.slot[n !== 1] = null;
      // l16 unary reductions on a literal
      jj.slot[&8'hFF] = null;
      jj.slot[~|8'h0F] = null;
      jj.slot[^~8'h33] = null;
      // l17 pre-increment / post-increment
      jj.slot[++n] = null;
      jj.slot[n++] = null;
      // l18 sys calls of several shapes
      jj.slot[n + $clog2(1024)] = null;
      jj.slot[n + $unsigned(3)] = null;
      jj.slot[n + $countones(8'hF0)] = null;
      jj.slot[n + $high(8'hF0)] = null;
      // l19 deeply parenthesised, mixed precedence, comments
      jj.slot[((n) + ((1)))] = null;
      jj.slot[(n /*a*/ + /*b*/ 1) * (2 /*c*/ - 3)] = null;
    endfunction
  endclass
endpackage
