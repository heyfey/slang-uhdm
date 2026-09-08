package pz1;
  import pz2::*;
  int z1_v;
endpackage
package pz2;
  import pz1::*;
  int z2_v;
endpackage
module mz; import pz1::*; logic mz_clk; endmodule
// v217 arm G — MUTUAL PACKAGE IMPORTS (a cycle).  Legal SV: slang rc=0 and
// Surelog reports 0 errors.  GOLDEN: `package pz1` lists ONLY z1_v (pz2's
// component vector was still empty when Surelog compiled pz1); `package pz2`
// lists [z1_v, z2_v]; `module mz`, which imports pz1, lists [z1_v, mz_clk].
// The pristine 48199935 binary gets `module mz` EXACTLY RIGHT; the r10uvm217
// patch as submitted hoists `z2_v` into it as well — a name golden does not
// hoist.  That is the regression this verifier fixes.
