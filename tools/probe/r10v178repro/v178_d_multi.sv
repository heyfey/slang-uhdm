// r10v178 VERIFIER ARM D — MULTIPLE HOMES AND MULTIPLE CLONES.
// MEASUREMENT ONLY.  ONE importer wildcard-imports THREE different home
// packages, so its listing carries THREE clone groups whose parameter homes
// differ; the law's term-2 walk must pick the RIGHT home for each.  A fourth
// package wildcard-imports only ONE of them.  A fifth EXPLICITLY imports one
// (a non-wildcard clone: `importCloneEmit`, NOT `pkgImportCloneEmit`).
// Deliberately unlike names/numbers/case; declaration order shuffled.

package Ha_V;   parameter int ha_k = 32'h1111_0001;
  function automatic int ha_rd(input int a); int r; r = a; r ^= ha_k; return r; endfunction
endpackage
package bB_V;   parameter int bb_k = 32'h2222_0002;
  function automatic int bb_rd(input int a); int r; r = a; r ^= bb_k; return r; endfunction
  function automatic int bb_two(input int a); int r; r = a; r ^= bb_k; r ^= bb_k; return r; endfunction
endpackage
package C3_V;   parameter int c3_k = 32'h3333_0003;
  function automatic int c3_rd(input int a); int r; r = a; r ^= c3_k; return r; endfunction
endpackage

// THREE clone groups in ONE listing.
package Tri_V;
  import Ha_V::*;
  import bB_V::*;
  import C3_V::*;
  parameter int tri_own = 32'h4444_0004;
  function automatic int tri_rd(input int a); int r; r = a; r ^= tri_own; return r; endfunction
endpackage

// ONE clone group.
package Uni_V;
  import bB_V::*;
endpackage

// EXPLICIT import: a different clone mechanism.
package Exp_V;
  import C3_V::c3_rd;
  import C3_V::c3_k;
  function automatic int exp_rd(input int a); int r; r = a; r ^= c3_k; return r; endfunction
endpackage

module m_v178d (input logic ck, output int d1, d2, d3, d4, d5, d6, d7);
  import Ha_V::*;
  import bB_V::*;
  import C3_V::*;
  import Tri_V::*;
  import Uni_V::*;
  import Exp_V::*;
  assign d1 = ha_rd(1);
  assign d2 = bb_rd(2);
  assign d3 = c3_rd(3);
  assign d4 = tri_rd(4);
  assign d5 = bb_two(5);
  assign d6 = exp_rd(6);
  assign d7 = d1 ^ d2;
endmodule
