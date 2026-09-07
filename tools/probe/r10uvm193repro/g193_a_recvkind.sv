// r10uvm193 ARM A — THE RECEIVER-KIND AXIS of
// § cloneArrayRecvArgMintsElemVar193.
//
// MEASUREMENT ONLY.  One real Surelog golden, both views, read with
// `ct193arg mfc`/`cenall` and scored with score193.py.  LHS is ALWAYS golden.
//
// The question this arm asks, one row per receiver kind: in a WILDCARD-IMPORT
// clone body, what does golden give the DIRECT NAME ARGUMENT of a method call
// written on that receiver?  The producer (UHDM
// `method_func_call::DeepClone`, clone_tree.cpp:150-180) asks only whether the
// RECEIVER's binding is an `array_var` with a non-empty `Variables()` list —
// so an ASSOCIATIVE array, a QUEUE, a DYNAMIC array, an UNPACKED array and an
// ARRAY ELEMENT all take the MINT, while a plain STRING takes the RECEIVER
// (§ cloneBuiltinMethodArgBindsReceiver184, whose arms and both fences must
// not move) and a CLASS PROPERTY receiver, which the clone leaves BARE, hands
// the argument nothing at all.
//
// The `_193` suffix on every name keeps this arm's census keys out of every
// other arm's.

package Quay193;

  int  assoc193[int];
  int  pkgtally193;

  // --- the clone-visible free functions -----------------------------------
  // Each one is re-emitted into every wildcard importer, which is the ONLY
  // listing this law fires in.

  function automatic int a1_assoc193(input int fml_a193);
    int  bag193[int];
    int  kink193;
    kink193 = 3;
    bag193[kink193] = 7;
    // A1  ASSOCIATIVE receiver, BUILT-IN method, direct name argument.
    if (bag193.exists(kink193)) fml_a193 = fml_a193 + 1;
    return fml_a193;
  endfunction

  function automatic int a2_queue193(input int fml_b193);
    int  rope193[$];
    int  kink193;
    kink193 = 1;
    rope193.push_back(9);
    // A2  QUEUE receiver, BUILT-IN method with a plain argument.
    rope193.delete(kink193);
    return rope193.size() + fml_b193;
  endfunction

  function automatic int a3_dyn193(input int fml_c193);
    int  limb193[];
    int  kink193;
    limb193 = new[4];
    kink193 = 2;
    // A3  DYNAMIC-array receiver.
    limb193[kink193] = 5;
    return limb193[kink193] + fml_c193;
  endfunction

  function automatic int a4_unpacked193(input int fml_d193);
    int  slab193[4];
    int  kink193;
    kink193 = 0;
    slab193[kink193] = 6;
    // A4  UNPACKED-array receiver, BUILT-IN reduction with a `with` clause is
    //     deliberately NOT written here — see arm B.
    return slab193[kink193] + fml_d193;
  endfunction

  function automatic string a5_strelem193(input int fml_e193);
    string skein193[3];
    int    gauge193;
    gauge193 = 1;
    skein193[0] = "sheave";
    // A5  A STRING ARRAY ELEMENT receiver.  The receiver expression's slang
    //     type IS a string, so § 184's own site gate passes — what keeps that
    //     law out is its recorder's receiver-KIND filter (the element is a
    //     `bit_select`, not a `ref_obj`/`ref_var`).  Golden's answer here is
    //     THIS law's mint, a `string_var` named after the ARGUMENT at the
    //     ARRAY's declaration span (r10v184's arm-D finding, its R2 widening).
    return skein193[0].substr(gauge193, gauge193 + 1) ;
  endfunction

  function automatic string a6_string193(input int fml_f193);
    string cable193;
    int    kink193;
    cable193 = "cablelaid";
    kink193 = 2;
    // A6  A PLAIN STRING receiver — § 184's own half of the SAME producer.
    //     Golden binds the argument to the RECEIVER, and it MUST STAY there.
    return cable193.substr(1, kink193);
  endfunction

  function automatic int a7_pkgarr193(input int fml_g193);
    int kink193;
    kink193 = 4;
    // A7  A PACKAGE-scope associative array as the receiver.
    if (assoc193.exists(kink193)) fml_g193 = fml_g193 + 1;
    return fml_g193 + pkgtally193;
  endfunction

  function automatic int a8_fmlarr193(input int fml_h193[], input int kink193);
    // A8  A FORMAL dynamic array as the receiver.
    return fml_h193[kink193] + fml_h193.size();
  endfunction

endpackage

// THE CLONE listing: a wildcard import re-emits every subroutine above.
package Barge193;
  import Quay193::*;
  function automatic int pull193(input int fml_k193);
    return fml_k193;
  endfunction
endpackage

// THE EXPLICIT-import copy (R1): golden treats it exactly like the wildcard
// clone and this law cannot fire there, because its listing gate is § 16's
// wildcard-only registry.  Corpus incidence: zero.
package Skiff193;
  import Quay193::a1_assoc193;
  function automatic int shove193(input int fml_l193);
    return fml_l193;
  endfunction
endpackage

module top193a;
  import Quay193::*;
  int q193[int];
  int r193;
  initial begin
    r193 = a1_assoc193(1) + a2_queue193(2) + a3_dyn193(3) + a4_unpacked193(4)
         + a7_pkgarr193(7) + Barge193::pull193(8) + Skiff193::shove193(9);
  end
endmodule
