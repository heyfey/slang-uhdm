// r10uvm208 arm G — THE THREE INHERITED FENCES, under the split.
//
//  * THE CLASS FENCE.  `declTf205`'s climb from a declaration stops at
//    `class_defn`, so a class PROPERTY is refused — the same refusal
//    `CloneBodyTdRebind180` makes on purpose ("those objects belong to the
//    class world both producers reach by other routes").
//  * THE RETURN-VARIABLE EXCEPTION (r10uvm169).  A clone function's RETURN
//    variable keeps the HOME's QUALIFIED target, so it counts as a NON-clone
//    owner and a chain it shares can never be split.
//  * THE OUTER-REF EXCLUSIVITY GUARD, this law's own: only a declaration whose
//    OWN `ref_typespec` is clone-exclusive may be re-pointed.
//
// The crossing shape of arm E sits alongside each fence in the same file, so
// the arm is a POSITIVE CONTROL as well: it must move the crossing cell and
// leave all three fenced cells exactly where they are, in both views.
package p208a_r;
  typedef bit [7:0] bt208;
  typedef bt208 arr208[];

  class Prop208;
    bt208 prop208[];              // THE CLASS PROPERTY — refused by the fence
    function int use208();
      int u208 = 0;
      foreach (prop208[i208])
        u208 += int'(prop208[i208]);
      return u208;
    endfunction
  endclass

  // a clone function whose RETURN TYPE is an array of the package typedef
  function automatic arr208 fr208(input int n208);
    bt208 body208[];
    fr208 = body208;
  endfunction

  // the crossing shape — the positive control in this arm
  function automatic int fu208(input int n208);
    bt208 loc208[];
    int   a208 = 0;
    foreach (loc208[i208])
      a208 += int'(loc208[i208]);
    return a208 + n208;
  endfunction
endpackage

package p208b_r;
  import p208a_r::*;
  function automatic int gr208();
    Prop208 p208;
    arr208  got208;
    p208 = new();
    got208 = fr208(1);
    return got208.size() + p208.use208() + fu208(1);
  endfunction
endpackage

module g208_g_fences;
  import p208b_r::*;
  int r208;
  initial r208 = gr208();
endmodule
