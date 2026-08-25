// r10uvm143 arm D — THE ONE CELL THE LAW MUST NOT TOUCH.
// `LocalScopeHierPath/testflags` (a CMP_EQUAL row) binds a path-element index
// inside an IN-BODY class method: `foreach (path.slices[j])`, where golden
// binds `j` to the foreach loop variable's `ref_var`.  Every branch of
// UhdmWriter::lateBinding REFUSES a ref_var/ref_obj candidate, so that binding
// cannot have come from the late-binding pool — a different mechanism made it,
// and § hpIdxClassBodyNeverLateBinds143 leaves it alone.
package Loom_pkg;

  typedef struct { string weftName; int pick; } Strand;

  class Warp;
    Strand fibres[];
    Strand mesh[int];
  endclass

  class Reed;

    // d1 — the corpus shape: a foreach ITERATOR over a member array of a
    //      local class handle, INSIDE the class body.  Expect: BOUND (ref_var)
    //      on both sides, before AND after the patch.
    function void combForeach();
      Warp bundles[$];
      foreach (bundles[b]) begin
        Warp thread = bundles[b];
        foreach (thread.fibres[j]) begin
          string tag = thread.fibres[j].weftName;
        end
      end
    endfunction

    // d2 — a foreach loop variable used as an ORDINARY path index in the body
    //      (not in the iterator header).
    function void combBodyIdx();
      Warp thread;
      thread = new();
      foreach (thread.fibres[k]) begin
        int got = thread.fibres[k].pick;
      end
    endfunction

    // d3 — a plain formal index in the same class, for contrast: this one IS
    //      the law's population (expect golden bare, ours bare after the fix).
    function int combFormal(Warp thread, int lane = 1);
      return thread.mesh[lane].pick;
    endfunction

  endclass

  // d4 — the OUT-OF-BODY twin of d3: expect BOUND on both sides.
  class Shuttle;
    Strand mesh2[int];
    extern function int glideFormal(int lane);
  endclass
  function int Shuttle::glideFormal(int lane);
    return mesh2[lane].pick;
  endfunction

endpackage

module loomTop;
  Loom_pkg::Reed reed;
  initial begin reed = new(); reed.combBodyIdx(); end
endmodule
