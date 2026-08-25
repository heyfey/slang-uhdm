// r10uvm130repro/g130_a2.sv — THE HOME GRID, and the arm that DECIDES the law.
// ONE declaration kind and ONE reference position (the BARE SIZE argument of a
// dynamic-array `new[...]`), written in SIX homes.  MEASUREMENT ONLY.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package p130b;

  class kls130b;
    int dynIn130b[];
    // an IN-BODY class method — Surelog never walks a CLASS's late-binding
    // list (UhdmWriter.cpp:1067 is commented out), so golden must leave this
    // one BARE and mint NO wire.
    function void inBodyBeta130b();
      int homeInBodyBeta130b;
      homeInBodyBeta130b = 5;
      dynIn130b = new[homeInBodyBeta130b];
    endfunction
    extern function void oobGamma130b();
  endclass

  // an OUT-OF-BODY method of a package class
  function void kls130b::oobGamma130b();
    int homeOobGamma130b;
    homeOobGamma130b = 6;
    dynIn130b = new[homeOobGamma130b];
  endfunction

  // a FREE PACKAGE FUNCTION
  int dynFree130b[];
  function void freeFnAlpha130b();
    int homeFreeFnAlpha130b;
    homeFreeFnAlpha130b = 7;
    dynFree130b = new[homeFreeFnAlpha130b];
  endfunction

  // a FREE PACKAGE TASK
  task freeTaskDelta130b();
    int homeFreeTaskDelta130b;
    homeFreeTaskDelta130b = 8;
    dynFree130b = new[homeFreeTaskDelta130b];
  endtask

endpackage

// a `$unit` FUNCTION
int dynUnit130b[];
function void unitFnZeta130b();
  int homeUnitFnZeta130b;
  homeUnitFnZeta130b = 9;
  dynUnit130b = new[homeUnitFnZeta130b];
endfunction

import p130b::*;

module top130b;
  int dynMod130b[];
  // a MODULE's OWN function
  function void modFnEps130b();
    int homeModFnEps130b;
    homeModFnEps130b = 10;
    dynMod130b = new[homeModFnEps130b];
  endfunction
  initial begin
    kls130b k130b;
    k130b = new();
    k130b.inBodyBeta130b();
    k130b.oobGamma130b();
    freeFnAlpha130b();
    freeTaskDelta130b();
    unitFnZeta130b();
    modFnEps130b();
  end
endmodule
