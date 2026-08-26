// r10v151 (VERIFIER) arm 7 — THE RANDOMIZE FORMS, statement AND expression,
// the must-stay control for § memberRandomizeWithIsRecvPath119 and
// § scopeRandomizeIsBareCall116.  MEASUREMENT ONLY.
// LHS is always golden (Surelog), RHS always ours.
package Qpk7;
  class Item7;
    rand int aa;
    rand int bb;
    constraint k7 { aa < 100; }
  endclass
  class Drv7;
    Item7 one;
    Item7 farm[3];
    rand int loc;
    task go7;
      int ok;
      // ---- STATEMENT position ----
      one.randomize();
      one.randomize(aa);
      one.randomize(aa, bb);
      one.randomize() with { aa > 1; };
      one.randomize(aa) with { aa > 2; };
      one.randomize with { aa > 3; };
      farm[1].randomize();
      farm[2].randomize() with { aa > 4; };
      randomize(loc);
      randomize(loc) with { loc > 5; };
      this.randomize();
      void'(one.randomize() with { aa > 6; });
      // ---- EXPRESSION position (119's own committed face) ----
      ok = one.randomize();
      ok = one.randomize() with { aa > 7; };
      if (!one.randomize() with { aa > 8; }) ok = 0;
      while (one.randomize() with { aa > 9; }) ok = 1;
      $display("%0d", one.randomize() with { aa > 10; });
      ok = one.randomize(aa) with { bb > 11; };
      ok = farm[0].randomize() with { aa > 12; };
    endtask
  endclass
endpackage
