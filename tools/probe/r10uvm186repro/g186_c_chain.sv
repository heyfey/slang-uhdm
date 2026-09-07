// r10uvm186 grid ARM C — THE CLONE-CHAIN axis.  Arm A varied the argument's
// declaration and arm B the listing; this arm varies HOW MANY clones deep the
// body is, and how many importers it is cloned into at once, because the gate
// is a single boolean (`pkgImportCloneEmit`) that is saved and restored around
// each clone emission and a nested or repeated clone is the face that could
// leave it stale.
//
//   Ratchet186   declares the bodies
//   Pawl186      wildcard-imports Ratchet186          — clone depth 1
//   Detent186    wildcard-imports Pawl186             — clone depth 2 (transitive)
//   Escape186    wildcard-imports Ratchet186 AND Pawl186 — two roads to one body
//
// Every clone listing must bind the `new[...]` argument to the home
// declaration; the Ratchet186 home listing must stay BARE.  Names, numbers and
// orders are deliberately unlike the corpus'.
package Ratchet186;
  class Sprocket186;
    int m_teeth;
    extern function int gear186(input int fml_p);
  endclass
  function int Sprocket186::gear186(input int fml_p);
    int dyn186[];
    int loc186;
    int src186[];
    loc186  = fml_p + 6;
    src186  = new[2];
    dyn186  = new[loc186];           // C1 body local, out-of-body class method
    dyn186  = new[loc186](src186);   // C2 copy source
    return dyn186.size() + m_teeth;
  endfunction
  function automatic int click186(input int fml_s, input int fml_bag[]);
    int dyn186[];
    int loc186;
    loc186 = fml_s + 7;
    dyn186 = new[loc186];            // C3 free function, body local
    dyn186 = new[fml_s](fml_bag);    // C4 formal size + formal copy source
    return dyn186.size();
  endfunction
endpackage

package Pawl186;
  import Ratchet186::*;
  int cog186 = 21;
  function automatic int use_pawl186();
    int bag186[];
    bag186 = new[2];
    return click186(3, bag186);
  endfunction
endpackage

package Detent186;
  import Pawl186::*;
  int shank186 = 22;
  function automatic int use_detent186();
    return use_pawl186();
  endfunction
endpackage

package Escape186;
  import Ratchet186::*;
  import Pawl186::*;
  int flute186 = 23;
  function automatic int use_escape186();
    int bag186[];
    Sprocket186 hub186;
    bag186 = new[3];
    hub186 = new();
    return click186(4, bag186) + hub186.gear186(5) + use_pawl186();
  endfunction
endpackage

module top186c;
  import Detent186::*;
  import Escape186::*;
  int scored186;
  initial begin
    scored186 = use_detent186() + use_escape186();
    $display("%0d", scored186);
  end
endmodule
