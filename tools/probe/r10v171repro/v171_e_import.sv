// r10v171 arm E — IMPORT KINDS and IMPORT CHAINS.  The patch's gate is
// `pkgImportCloneEmit`, which the emitter sets for the WILDCARD package-import
// clone and NOT for the explicit (`import pkg::name;`) one, and not for a
// module's import at all.  This arm asks golden what it does at each of those
// doors, and whether a two-hop import chain (A -> B -> C) re-clones.
package impa_171;
  function string a_fn();
    int ka;
    a_fn = "alpha";
    ka = a_fn.len() - 1;
    a_fn[0] = a_fn[ka];
  endfunction
  function string a_two();
    int kb;
    a_two = "alphatwo";
    kb = a_two.len() - 1;
    a_two[0] = a_two[kb];
  endfunction
endpackage

// (E1) WILDCARD import — the law's own door.
package impb_wild_171;
  import impa_171::*;
  function int b_use();
    return a_fn().len() + a_two().len();
  endfunction
endpackage

// (E2) EXPLICIT import of the same free function.
package impc_expl_171;
  import impa_171::a_fn;
  function int c_use();
    return a_fn().len();
  endfunction
endpackage

// (E3) TWO-HOP chain: impd wildcard-imports impb_wild_171, which itself
//      wildcard-imported impa_171.
package impd_chain_171;
  import impb_wild_171::*;
  function int d_use();
    return b_use();
  endfunction
endpackage

// (E4) a package that BOTH wildcard-imports and calls with the explicit
//      `pkg::` qualification — the qualified spelling must not clone.
package impe_qual_171;
  import impa_171::*;
  function int e_use();
    return impa_171::a_fn().len() + a_two().len();
  endfunction
endpackage

// (E5) MODULE-level wildcard import: no package clone at all.
module imp_mod_171;
  import impa_171::*;
  int mr;
  initial mr = a_fn().len();
endmodule

module imp_top_171;
  import impc_expl_171::*;
  import impd_chain_171::*;
  import impe_qual_171::*;
  imp_mod_171 um();
  int tr;
  initial tr = c_use() + d_use() + e_use();
endmodule
