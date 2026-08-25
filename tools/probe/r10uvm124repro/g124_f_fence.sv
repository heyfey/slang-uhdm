// r10uvm124 arm F — the FENCES and the MULTIPLICITY axis.  Receivers with no
// select at all, a `this`-rooted receiver, a receiver whose subscript holds a
// call (the index text that `decompileHelper` renders EMPTY), a package-scoped
// receiver, and the SAME indexed statement call written one, two and three
// times so a cell that moves is counted, not merely seen.
package Fence124;
  class Vial;
    int Drops[$];
  endclass
  function automatic int Pick(int V); return V; endfunction
  class Tray;
    Vial Wells[$];
    Vial Solo;
    int  Flat[$];
    task automatic Mix(int Ax);
      Solo.Drops.push_back(401);           // FENCE: receiver has no select
      Flat.push_back(402);                 // FENCE: no select, no chain
      this.Flat.push_back(403);            // FENCE: `this` receiver
      Wells[Pick(Ax)].Drops.push_back(404);// subscript holds a CALL
      Wells[Ax].Drops.push_back(405);      // instance 1 of 3
      Wells[Ax].Drops.push_back(406);      // instance 2 of 3
      Wells[Ax].Drops.push_back(407);      // instance 3 of 3
      Wells[Ax+1].Drops.push_back(408);    // subscript holds an OPERATION
    endtask
  endclass
endpackage
