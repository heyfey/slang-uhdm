// r10v152 arm E — POSITIONS.  The eaten declaration read from every position
// that § 81's early-bound exception separates, side by side with a § 81 FORMAL
// of a package subroutine read from the same positions (the must-stay control).
package pospkg;

  class Cog; int cg; endclass

  int    ctr;
  Cog    frm_name;                 // package var colliding with the formals below

  class Poser;
    int pz;
    extern function new();
  endclass

  function Poser::new();
    Cog eat_name;                  // EATEN
    Cog loc_name;                  // ordinary local, the control
    if (eat_name == null) ctr = 1;            // e01 if predicate   (eaten)
    if (loc_name == null) ctr = 2;            // e02 if predicate   (local)
    case (eat_name)                            // e03 case condition (eaten)
      null: ctr = 3;
      default: ctr = 4;
    endcase
    case (loc_name)                            // e04 case condition (local)
      null: ctr = 5;
      default: ctr = 6;
    endcase
    while (eat_name != null) ctr = 7;          // e05 while cond    (eaten)
    while (loc_name != null) ctr = 8;          // e06 while cond    (local)
    for (int q = 0; q < 2; q++)
      if (eat_name == null) ctr = 9;           // e07 nested if pred
    eat_name = null;                           // e08 lvalue        (eaten)
    loc_name = null;                           // e09 lvalue        (local)
    ctr = (eat_name == null) ? 10 : 11;        // e10 ternary       (eaten)
    ctr = (loc_name == null) ? 12 : 13;        // e11 ternary       (local)
    sink(eat_name);                            // e12 call argument (eaten)
    sink(loc_name);                            // e13 call argument (local)
    begin : named_blk
      if (eat_name == null) ctr = 14;          // e14 named block pred
    end
    begin
      if (loc_name == null) ctr = 15;          // e15 unnamed block pred
    end
    pz = 1;
  endfunction

  function void sink(Cog c);
    ctr = ctr + 1;
  endfunction

  // § 81 MUST-STAY: a package subroutine whose FORMAL collides with a package
  // variable.  The predicate keeps the formal; every other position takes the
  // package variable.
  function void eighty_one(Cog frm_name);
    if (frm_name == null) ctr = 20;            // e20 predicate -> FORMAL
    frm_name = null;                           // e21 lvalue    -> package var
    ctr = (frm_name == null) ? 22 : 23;        // e22 ternary   -> package var
    case (frm_name)                            // e23 case cond -> FORMAL
      null: ctr = 24;
      default: ctr = 25;
    endcase
  endfunction

endpackage

module mpos;
  import pospkg::*;
  Poser pv;
  initial begin
    pv = new();
    eighty_one(null);
  end
endmodule
