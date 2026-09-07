// r10uvm191 grid ARM C — THE DECLARATION-SCOPE AXIS.
//
// `bind9` resolves a clone-body name in three places, in this order: a
// `foreach` LOOP VARIABLE and a BLOCK local found by CLIMBING the anchor's
// parent chain, and the subroutine-level map (`pkgCloneBodyLocals9`) as the
// last resort.  Under a dynamic-array `new[...]` that climb is dead for the
// same reason the owning-subroutine walk is, which is why the shipped hop is
// taken by BOTH.  This arm is what convicted a hop taken by only one: the
// corpus's own `sys_addr` (uvm-1.2 `uvm_reg_map.svh:1472`, read at :1491) is
// a BLOCK local, and with the hop in `ownerTf9` alone that one key of the
// four stayed bare while the three function-level locals moved.
//
// One row per DECLARING SCOPE, all at the same face (a hier_path base under
// `new[...]` in a wildcard-import clone): a function-level local, a NAMED
// block local, an UNNAMED block local, a nested block local, a formal, a
// `for` iterator's block, a class property (the fence) and a package
// variable (never in the silence at all).  A `bit_select` base and a
// two-level path are here too, because `bindable37` accepts a `bit_select`
// and the § 37 sweep would reach one through the same hop.
//
// Names, numbers and orders are deliberately unlike the corpus'.
package Voussoir191;

  typedef struct packed { int gable191; int size; } Quoin191;

  int pkgcask191[string];

  class Impost191;
    int m_wain191[string];
    extern function int haunch191(input int fml_g, input int fml_arr[]);
  endclass

  function int Impost191::haunch191(input int fml_g, input int fml_arr[]);
    int      dyn191[];
    int      lvl191[string];        // C1 FUNCTION-LEVEL local
    Quoin191 shelf191[];            // C9 an array of struct
    int      tot191;

    lvl191["p"] = 1;
    shelf191 = new[2];
    tot191 = 0;

    dyn191 = new[lvl191.size()];        // C1 function-level local
    dyn191 = new[fml_arr.size()];       // C2 a FORMAL dynamic array
    dyn191 = new[m_wain191.size()];     // C3 a CLASS PROPERTY  — THE FENCE
    dyn191 = new[pkgcask191.size()];    // C4 a PACKAGE variable

    begin : cove191
      int nbl191[string];
      nbl191["q"] = 2;
      dyn191 = new[nbl191.size()];      // C5 a NAMED-block local
    end
    begin
      int ubl191[$];
      ubl191.push_back(3);
      dyn191 = new[ubl191.size()];      // C6 an UNNAMED-block local
      begin
        int deep191[string];
        deep191["r"] = 4;
        dyn191 = new[deep191.size()];   // C7 a NESTED unnamed-block local
      end
    end
    for (int itr191 = 0; itr191 < 2; itr191++) begin
      int forl191[$];
      forl191.push_back(itr191);
      dyn191 = new[forl191.size()];     // C8 a `for` BODY block local
    end
    foreach (shelf191[ix191])
      dyn191 = new[shelf191[ix191].gable191];  // C9 a bit_select BASE
    dyn191 = new[shelf191[0].size];            // C10 a struct MEMBER `size`

    return tot191 + dyn191.size() + fml_g;
  endfunction

  function automatic int gambrel191(input int fml_h);
    int dyn191[];
    int purl191[string];
    purl191["s"] = fml_h;
    dyn191 = new[purl191.size()];       // C20 a FREE package function
    return dyn191.size();
  endfunction

endpackage

package Spandrel191;
  import Voussoir191::*;
  int wane191 = 14;
  function automatic int use_sp191();
    Impost191 im191;
    int       feed191[];
    feed191 = new[2];
    im191 = new();
    return im191.haunch191(5, feed191) + gambrel191(6) + wane191;
  endfunction
endpackage

module top191c;
  import Spandrel191::*;
  int scored191;
  initial begin
    scored191 = use_sp191();
    $display("%0d", scored191);
  end
endmodule
