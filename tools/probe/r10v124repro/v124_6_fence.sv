// r10v124 arm 6 — FENCES: a CALL-RESULT receiver, an index that is itself a
// call, an index that is an operation, a parenthesised/dotted index, and a
// receiver with NO select.  These must all be REFUSED or unchanged.
package Gate;
  typedef int Rope[$];

  class Knot;
    int mark;
    function int idx(); return 1; endfunction
    function string tag(); return "t"; endfunction
  endclass

  class Warden;
    Rope Slots[string];
    Rope Bays[4];
    Knot Keeper;

    function Rope fetch();
      return Bays[0];
    endfunction

    function void guard(string kx, int ix);
      Slots[Keeper.tag()].push_back(301);
      Bays[Keeper.idx()].push_back(302);
      Bays[(ix + 1) % 4].push_back(303);
      Slots[{kx, "z"}].push_back(304);
      Bays[ix].push_back(305);
      Slots[kx].push_back(306);
    endfunction
  endclass
endpackage

module Sentry;
  Gate::Warden wd;
  initial begin
    wd = new();
    wd.guard("a", 2);
  end
endmodule
