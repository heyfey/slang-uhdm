// r10uvm148 arm E — THE EARLY-BOUND LADDER and the NESTED-BLOCK fence.
// MEASUREMENT ONLY.  § condPredEarlyBound81 says a reference compiled with the
// ENCLOSING STATEMENT as `pexpr` binds EARLY and never enters the pool the
// package listing overwrites — which the corpus proves on ONE name in ONE
// body (`top` @3432:14 keeps the local, `top` @3410:48 takes the package).
// This arm walks that ladder deliberately and adds the nested-`begin` fence:
// a deeper block's own local is listed on ITS `begin` under BOTH productions,
// so Surelog's `uhdmbegin` arm `break`s and it is immune.
package earlypkg148;
  int    dogleg;
  int    splay;
  string tessera;

  function void tf_ladder148;
    int    dogleg;
    int    splay;
    string tessera;
    dogleg  = 1;
    tessera = "coping";
    // depth 0 — the predicate's enclosing statement is the body wrapper begin,
    // which already carries a parent chain to the function: EARLY BOUND.
    if (dogleg == 1) splay = 1;
    case (dogleg)                    // a case CONDITION at depth 0
      1: splay = 2;
      default: splay = 3;
    endcase
    // depth 1 — a plain begin above the predicate: still early bound.
    begin
      if (dogleg == 2) splay = 4;
    end
    // depth 2 — two plain begins.
    begin
      begin
        if (dogleg == 3) splay = 5;
      end
    end
    // ONE loop statement in the chain breaks it: LATE BOUND.
    for (int i = 0; i < 2; i++) begin
      if (dogleg == 4) splay = 6;
    end
    while (splay < 8) begin
      if (dogleg == 5) splay = splay + 1;
    end
    // ONE conditional statement in the chain breaks it too, on the ELSE side.
    if (splay == 99) begin
      splay = 7;
    end
    else begin
      if (dogleg == 6) splay = 8;    // nested under an ElseClause
    end
  endfunction

  // a FORK block in the chain, in a TASK (a function may not pass time)
  task tf_fork148;
    input int seed;
    int    dogleg;
    int    splay;
    dogleg = seed;
    if (dogleg == 7) splay = 9;      // depth 0 -> early bound
    fork
      begin
        if (dogleg == 8) splay = 10; // under a fork -> late bound
      end
    join
  endtask

  // The FORMAL twin of the same ladder — § pkgSubRefBindsPkgVarOverFormal81's
  // own population, measured here so the shared `condPredEarlyBound81` gate is
  // read off golden for BOTH halves at every rung.
  int gimbal;
  task formal_e148(input int gimbal);
    int keel;
    keel = gimbal;                   // a plain READ -> late bound
    if (gimbal == 1) keel = 2;       // depth 0 -> early bound
    begin
      if (gimbal == 2) keel = 3;     // one plain begin -> early bound
    end
    for (int i = 0; i < 2; i++) begin
      if (gimbal == 3) keel = 4;     // under a loop -> late bound
    end
    fork
      begin
        if (gimbal == 4) keel = 5;   // under a fork -> MEASURED, not assumed
      end
    join
  endtask

  // The NESTED-BLOCK fence: `dogleg` here is declared inside an inner named
  // block, so it is listed on THAT begin under both productions.
  function void tf_nested148;
    int splay;
    splay = 0;
    begin : nook148
      int dogleg;
      dogleg = 11;
      splay  = dogleg;
      if (dogleg == 11) splay = 12;
    end
    for (int i = 0; i < 2; i++) begin : cranny148
      string tessera;
      tessera = "lierne";
      $display("%s", tessera);
    end
  endfunction

  // The same ladder under the BLOCK-ITEM production: nothing may move here.
  function void bi_ladder148();
    int    dogleg;
    int    splay;
    string tessera;
    dogleg  = 1;
    tessera = "coping";
    if (dogleg == 1) splay = 1;
    for (int i = 0; i < 2; i++) begin
      if (dogleg == 4) splay = 6;
    end
    while (splay < 8) begin
      if (dogleg == 5) splay = splay + 1;
    end
  endfunction
endpackage

module earlytop148;
  import earlypkg148::*;
  initial begin
    tf_ladder148();
    tf_fork148(7);
    formal_e148(1);
    tf_nested148();
    bi_ladder148();
  end
endmodule
