// r10v148 arm E — THE EARLY-BOUND LADDER, widened: fork/join, join_any,
// join_none, NAMED fork, fork under a loop, a loop under a fork, `case`
// condition and item, an immediate assertion, and the FORMAL twin of every
// rung.  MEASUREMENT ONLY.  This arm exists to convict or acquit r10uvm148's
// removal of `ParallelBlockStatement` from `condPredEarlyBound81`'s breaker
// list, and to prove § 81's FORMAL half did not regress anywhere else.
package v5_pkg;
  int   quoin;
  int   voussoir;
  int   spandrel;

  // ---------- TF-ITEM LOCAL half ----------
  task lad_tf_v5;
    input int seed;
    int quoin;
    int voussoir;
    quoin = seed;
    if (quoin == 1) voussoir = 1;             // L0  depth 0
    begin
      if (quoin == 2) voussoir = 2;           // L1  one plain begin
    end
    fork
      begin
        if (quoin == 3) voussoir = 3;         // L2  fork/join + begin
      end
    join
    fork
      if (quoin == 4) voussoir = 4;           // L3  fork/join, no begin
    join
    fork
      begin
        if (quoin == 5) voussoir = 5;         // L4  join_any
      end
    join_any
    fork
      begin
        if (quoin == 6) voussoir = 6;         // L5  join_none
      end
    join_none
    fork : nfk_v5
      begin
        if (quoin == 7) voussoir = 7;         // L6  NAMED fork
      end
    join
    for (int i = 0; i < 2; i++) begin
      fork
        begin
          if (quoin == 8) voussoir = 8;       // L7  fork under a LOOP
        end
      join
    end
    fork
      begin
        for (int i = 0; i < 2; i++) begin
          if (quoin == 9) voussoir = 9;       // L8  LOOP under a fork
        end
      end
    join
    fork
      begin
        quoin = 10;                           // L9  a plain LVALUE under a fork
        voussoir = quoin;                     // L10 a plain READ under a fork
      end
    join
    case (quoin)                              // L11 case CONDITION, depth 0
      1: voussoir = 11;
      default: voussoir = 12;
    endcase
    fork
      begin
        case (quoin)                          // L12 case CONDITION under a fork
          1: voussoir = 13;
          default: voussoir = 14;
        endcase
      end
    join
    assert (quoin != 99);                     // L13 immediate assertion, depth 0
    fork
      begin
        assert (quoin != 98);                 // L14 assertion under a fork
      end
    join
  endtask

  // ---------- FORMAL half (§ 81's own population) ----------
  task lad_fm_v5(input int quoin);
    int keel_v5;
    keel_v5 = quoin;                          // F0  plain READ -> late bound
    if (quoin == 1) keel_v5 = 1;              // F1  depth 0
    begin
      if (quoin == 2) keel_v5 = 2;            // F2  one plain begin
    end
    fork
      begin
        if (quoin == 3) keel_v5 = 3;          // F3  fork/join + begin
      end
    join
    fork
      if (quoin == 4) keel_v5 = 4;            // F4  fork/join, no begin
    join
    fork
      begin
        if (quoin == 5) keel_v5 = 5;          // F5  join_none
      end
    join_none
    fork : nfk2_v5
      begin
        if (quoin == 6) keel_v5 = 6;          // F6  NAMED fork
      end
    join
    for (int i = 0; i < 2; i++) begin
      if (quoin == 7) keel_v5 = 7;            // F7  under a LOOP -> late bound
    end
    fork
      begin
        quoin = 8;                            // F8  LVALUE under a fork
        keel_v5 = quoin;                      // F9  READ under a fork
      end
    join
    fork
      begin
        for (int i = 0; i < 2; i++) begin
          if (quoin == 9) keel_v5 = 9;        // F10 LOOP under a fork
        end
      end
    join
  endtask

  // ---------- BLOCK-ITEM twin: nothing here may move ----------
  task lad_bi_v5;
    int quoin;
    int voussoir;
    quoin = 1;
    if (quoin == 1) voussoir = 1;
    fork
      begin
        if (quoin == 3) voussoir = 3;
      end
    join
    for (int i = 0; i < 2; i++) begin
      if (quoin == 8) voussoir = 8;
    end
  endtask
endpackage

module v148_e_top;
  initial begin
    v5_pkg::lad_tf_v5(1);
    v5_pkg::lad_fm_v5(1);
    v5_pkg::lad_bi_v5();
  end
endmodule
