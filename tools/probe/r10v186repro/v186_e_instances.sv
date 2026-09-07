// r10v186 (VERIFIER) ARM E — THE INSTANCE-COUNT AXIS, i.e. the § 130 HOIST
// POOL under the lifted gate.
//
// The gate the patch moves is read INSIDE the branch that also pushes the
// reference onto § newArrayArgHoistNet130's hoisted-net pool
// (`pkgFreeSubPropRefs117` / `classPropRefs`, ExprEmit.cpp ~17348).  Making
// `newArrayArgNoBind16` FALSE in a clone therefore ALSO stops the clone
// emission from pushing that pool entry — and § 130's whole job is to mint an
// implicit wire in EVERY module that hoists the body's package.  With ONE
// module the loss of one pool push can be invisible; with THREE modules
// hoisting the same package through the same clone it cannot be.  This arm
// instantiates the importer in one, two and three module instances at once
// and reads the hoisted nets in both views on one real Surelog golden.
//
// Names, numbers and orders deliberately unlike the corpus' and unlike
// r10uvm186's own arms.
package Volute186v;
  function automatic int flute186v(input int in_a, input int in_src[]);
    int dyn186v[];
    int cinct186v;
    int lsrc186v[];
    cinct186v = in_a + 1;
    lsrc186v  = new[2];
    dyn186v = new[cinct186v];            // E1 a body local
    dyn186v = new[in_a];                 // E2 a formal
    dyn186v = new[cinct186v](lsrc186v);  // E3 a copy source, body local
    dyn186v = new[cinct186v](in_src);    // E4 a copy source, a FORMAL
    return dyn186v.size() + lsrc186v.size();
  endfunction
endpackage

package Abacus186v;
  import Volute186v::*;
  function automatic int use_abacus186v(input int seed);
    int feed186v[];
    feed186v = new[2];
    return flute186v(seed, feed186v);
  endfunction
endpackage

// ONE instance of the importer.
module dentil186v(output int out_p);
  import Abacus186v::*;
  assign out_p = use_abacus186v(1);
endmodule

// The SAME importer hoisted into a module instantiated THREE times.
module guttae186v #(parameter int TAG = 0) (output int out_q);
  import Abacus186v::*;
  assign out_q = use_abacus186v(TAG + 2);
endmodule

module top186ve;
  int p186v, q1186v, q2186v, q3186v;
  dentil186v d186v(.out_p(p186v));
  guttae186v #(.TAG(1)) g1186v(.out_q(q1186v));
  guttae186v #(.TAG(2)) g2186v(.out_q(q2186v));
  guttae186v #(.TAG(3)) g3186v(.out_q(q3186v));
  initial $display("%0d", p186v + q1186v + q2186v + q3186v);
endmodule
