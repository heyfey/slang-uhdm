// r10v178 VERIFIER ARM A — PARAMETER KIND x CLONE.  MEASUREMENT ONLY.
// The law suppresses the bind for a HOME-package parameter read inside a
// wildcard-import clone.  This arm varies WHAT KIND of package-level constant
// is being read, because `pkgParamConst` / `pkgParamDefRhs` feed three
// different branches of the bind the law wraps.
//   plain parameter / typed parameter / localparam / string parameter /
//   a parameter whose Rhs is an OPERATION (non-constant chain) /
//   a parameter whose Rhs is a CONCATENATION.
// Names, numbers and declaration order deliberately unlike each other.

package Zeta_home_V;
  parameter        Bare_V   = 32'hdead_0001;      // untyped
  parameter int    typed7_V = 32'h0000_0202;      // typed
  localparam int   loc9_V   = 32'h5555_0303;      // localparam
  parameter string txt_V    = "quinine";          // string
  parameter int    opA_V    = 17;
  parameter int    opChain_V = opA_V + 4;         // operation Rhs
  parameter        cat_V    = {8'hab, 8'hcd};     // concatenation Rhs

  function automatic int unsigned zh_bare(input int unsigned q);
    int unsigned r; r = q; r ^= Bare_V;   return r;
  endfunction
  function automatic int unsigned zh_typed(input int unsigned q);
    int unsigned r; r = q; r ^= typed7_V; return r;
  endfunction
  function automatic int unsigned zh_loc(input int unsigned q);
    int unsigned r; r = q; r ^= loc9_V;   return r;
  endfunction
  function automatic int unsigned zh_chain(input int unsigned q);
    int unsigned r; r = q; r ^= opChain_V; return r;
  endfunction
  function automatic int unsigned zh_cat(input int unsigned q);
    int unsigned r; r = q; r ^= cat_V;    return r;
  endfunction
  function automatic int zh_str(input int q);
    int r; r = q;
    if (txt_V == "quinine") r = r + 1;
    return r;
  endfunction
endpackage

// ONE wildcard importer -> one clone of the whole listing above.
package Omicron_imp_V;
  import Zeta_home_V::*;
  parameter int local_only_V = 9;
  function automatic int unsigned own_here_V(input int unsigned q);
    int unsigned r; r = q; r ^= local_only_V; return r;
  endfunction
endpackage

module m_v178a (input logic ck, output int unsigned z1, z2, z3, z4, z5, output int z6, output int unsigned z7);
  import Zeta_home_V::*;
  import Omicron_imp_V::*;
  assign z1 = zh_bare(32'd7);
  assign z2 = zh_typed(32'd8);
  assign z3 = zh_loc(32'd9);
  assign z4 = zh_chain(32'd10);
  assign z5 = zh_cat(32'd11);
  assign z6 = zh_str(12);
  assign z7 = own_here_V(32'd13);
endmodule
