// r10v152 arm G — EDGES.  A KIND-MISMATCHED name collision, a constructor whose
// first element is `super.new()` (so the declaration is NOT eaten), a nested
// class, and the eaten name read from a fork arm and a foreach body.
package edgepkg;

  class Pin; int pp; endclass

  string  clash;                    // package var, STRING kind
  int     tally;
  int     arr[4];

  class Mismatch;
    int mz;
    extern function new();
  endclass
  function Mismatch::new();
    Pin clash;                      // g01 EATEN, CLASS kind vs package STRING
    Pin keeper;                     // g02
    clash  = null;
    keeper = null;
    mz = 1;
  endfunction

  class Base;
    int bz;
    function new(); bz = 0; endfunction
  endclass

  class Derived extends Base;
    int dz;
    extern function new();
  endclass
  function Derived::new();
    super.new();                    // FIRST element is super.new -> eaten
    begin
      Pin not_eaten;                // g03 a nested-block declaration
      not_eaten = null;
    end
    dz = 2;
  endfunction

  Pin not_eaten;                    // package var of the same name

  class Forker;
    int fz;
    extern function new();
  endclass
  function Forker::new();
    Pin fork_seen;                  // g04 EATEN
    Pin loop_seen;                  // g05
    fork
      if (fork_seen == null) tally = 3;   // g06 fork arm, eaten
      if (loop_seen == null) tally = 4;   // g07 fork arm, local
    join_none
    foreach (arr[i])
      if (fork_seen == null) tally = 5;   // g08 foreach body, eaten
    fz = 3;
  endfunction

endpackage

module medge;
  import edgepkg::*;
  Mismatch mm; Derived dd; Forker ff;
  initial begin
    mm = new(); dd = new(); ff = new();
  end
endmodule
