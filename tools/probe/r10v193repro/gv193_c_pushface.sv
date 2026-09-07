// r10v193 (ADVERSARIAL VERIFIER) ARM C — THE `pushVar` HALF and the NESTED
// faces of § cloneArrayRecvArgMintsElemVar193.
//
// MEASUREMENT ONLY.  One real Surelog golden, both views; LHS is ALWAYS
// golden.
//
// The producer pushes each mint into the elaborator's scope and pops it only
// after the `With()` clause, so a LATER reference of that NAME under the SAME
// call resolves to the mint.  The shipped drain models that with a
// CONTAINMENT walk (`e->VpiParent() == n`) over the LATER arguments and the
// `With()` clause.  This arm asks the walk's over-reach questions the
// implementer's arms do not:
//
//   C1  the producer's OWN cited example — `q.unique(it) with (it.field)`,
//       the comment at clone_tree.cpp:150 — where the argument IS the
//       iterator name and the `With()` clause references it again;
//   C2  a reference to the argument's name BEFORE the call and AFTER the
//       call, in the same body — neither is under the call, so neither may
//       move (the regression §5 of the pass README records);
//   C3  a NESTED call as an argument (`bag.exists(helper(pin))`) — not a
//       `ref_obj`, so refused, AND its inner `pin` sits inside a later
//       argument's subtree, which is where a reachability walk would leak;
//   C4  a DOTTED later argument whose LAST element carries the mint's name
//       (`bag.exists(pin, hull.pin_v193)`) — a hier_path member named like
//       the mint;
//   C5  the SAME name written as argument 0 and argument 1;
//   C6  an argument inside an OPERATION that also names the minting
//       argument (`bag.exists(pin, pin + 1)`);
//   C7  a call with NO arguments at all (nothing to mint);
//   C8  a method call written on an array receiver inside ANOTHER call's
//       argument list.

package Pontoon_v193;

  class Fender_v193;
    int pin_v193;
    int m_id_v193;
    function new(); pin_v193 = 1; m_id_v193 = 2; endfunction
    function int get_id_v193(); return m_id_v193; endfunction
    function int two_v193(input int a_v193, input int b_v193);
      return a_v193 + b_v193 + m_id_v193;
    endfunction
  endclass

  function automatic int helper_v193(input int seed_v193);
    return seed_v193 + 1;
  endfunction

  // C1  the producer's own comment case: `unique(it) with (it.get_id)`.
  function automatic int c1_uniqwith_v193(input int fml_a_v193);
    Fender_v193 gear_v193[$];
    Fender_v193 one_v193;
    Fender_v193 pick_v193[$];
    one_v193 = new();
    gear_v193.push_back(one_v193);
    pick_v193 = gear_v193.unique(cb_v193) with (cb_v193.get_id_v193());
    return fml_a_v193 + pick_v193.size();
  endfunction

  // C2  the SAME name before and after the call — must not move.
  function automatic int c2_beforeafter_v193(input int fml_b_v193);
    int bag_v193[int];
    int pin_v193;
    pin_v193 = 2;
    bag_v193[pin_v193] = 1;
    if (bag_v193.exists(pin_v193)) fml_b_v193 = fml_b_v193 + 1;
    pin_v193 = pin_v193 + 1;
    return fml_b_v193 + pin_v193;
  endfunction

  // C3  a NESTED call as the argument.
  function automatic int c3_nested_v193(input int fml_c_v193);
    int bag_v193[int];
    int pin_v193;
    pin_v193 = 3;
    bag_v193[pin_v193] = 1;
    if (bag_v193.exists(helper_v193(pin_v193))) fml_c_v193 = fml_c_v193 + 1;
    return fml_c_v193;
  endfunction

  // C4  a DOTTED later argument whose member carries the mint's name.
  function automatic int c4_dottedlater_v193(input int fml_d_v193);
    Fender_v193 hull_v193[$];
    Fender_v193 one_v193;
    int         pin_v193;
    one_v193 = new();
    hull_v193.push_back(one_v193);
    pin_v193 = 0;
    return fml_d_v193 + hull_v193[pin_v193].two_v193(pin_v193, one_v193.pin_v193);
  endfunction

  // C5  the SAME name at argument 0 AND argument 1.
  function automatic int c5_twice_v193(input int fml_e_v193);
    Fender_v193 hull_v193[$];
    Fender_v193 one_v193;
    int         pin_v193;
    one_v193 = new();
    hull_v193.push_back(one_v193);
    pin_v193 = 0;
    return fml_e_v193 + hull_v193[pin_v193].two_v193(pin_v193, pin_v193);
  endfunction

  // C6  a later argument that is an OPERATION naming the minting argument.
  function automatic int c6_operlater_v193(input int fml_f_v193);
    Fender_v193 hull_v193[$];
    Fender_v193 one_v193;
    int         pin_v193;
    one_v193 = new();
    hull_v193.push_back(one_v193);
    pin_v193 = 0;
    return fml_f_v193 + hull_v193[pin_v193].two_v193(pin_v193, pin_v193 + 1);
  endfunction

  // C7  a call with NO arguments at all.
  function automatic int c7_noarg_v193(input int fml_g_v193);
    int bag_v193[int];
    bag_v193[1] = 1;
    return fml_g_v193 + bag_v193.num();
  endfunction

  // C8  an array-receiver call INSIDE another call's argument list.
  function automatic int c8_inner_v193(input int fml_h_v193);
    int bag_v193[int];
    int pin_v193;
    pin_v193 = 8;
    bag_v193[pin_v193] = 1;
    return fml_h_v193 + helper_v193(bag_v193.exists(pin_v193));
  endfunction

endpackage

// THE CLONE listing.
package Gangway_v193;
  import Pontoon_v193::*;
  function automatic int cross_v193(input int fml_i_v193);
    return fml_i_v193;
  endfunction
endpackage

module topv193c;
  import Pontoon_v193::*;
  int r_v193;
  initial begin
    r_v193 = c1_uniqwith_v193(1) + c2_beforeafter_v193(2) + c3_nested_v193(3)
           + c4_dottedlater_v193(4) + c5_twice_v193(5) + c6_operlater_v193(6)
           + c7_noarg_v193(7) + c8_inner_v193(8) + Gangway_v193::cross_v193(9);
  end
endmodule
