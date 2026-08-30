// r10uvm164 ARM D -- THE MUST-STAY MATRIX.  Everything the term must NOT touch.
// S castOperandNeverBindsInCondWindow164.  MEASUREMENT ONLY.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// Three families, each a way the one-line un-scoping could over-reach:
//   D1  a reference with NO cast above it, in every one of the seven contexts
//       -- the whole point of the term is that it is the CAST and not the
//       position, so every bare twin here must keep the value it had;
//   D2  a cast OUTSIDE the condition window (a body statement, a loop control,
//       an event control, a `wait`, a `case ... inside` item, a fork arm) --
//       positions `condMethodWindowDepth164` is never raised at;
//   D3  the neighbouring LAWS whose windows share the same reference gate:
//       S refVarLocalWindowBinds5's DEPTH half (a condition one control body
//       deeper than the declaration is golden-bare and must STAY bare -- this
//       is the very shape of the seven sibling `action` references at
//       uvm_report_handler.svh:355-361), S namedBlkLocalNoBind144v's
//       condition-column twin (r10v161 left it standing on purpose and this
//       pass keeps its counter separate so it CANNOT move), and
//       S assertCondIsAClassMethodWindow161's own assert / case-item column.
package pk_stay164;
  int unsigned tessera = 13;
endpackage

class Stay164;
  int    coping = 61;
  event  chime;

  // ---- D1: NO CAST, the seven contexts ------------------------------
  function automatic int no_cast(int unsigned span, bit [3:0] gnomon);
    int    lintel = 71;
    string tale;
    if (lintel == 71)          coping = 1;              // d01 ifcond   bare LOCAL
    if (span == 5)             coping = 2;              // d02 ifcond   bare FORMAL
    case (lintel)
      71:      coping = 3;                              // d03 casecond bare LOCAL
      default: coping = 4;
    endcase
    case (gnomon)
      4'(lintel): coping = 5;                           // d04 caseitem CAST (S 161's)
      lintel[3:0]: coping = 6;                          // d05 caseitem bare
      default:     coping = 7;
    endcase
    assert (lintel == 71);                              // d06 assertcond bare
    assert (int'(lintel) == 71);                        // d07 assertcond CAST (S 161's)
    tale = $sformatf("%0d", lintel);                    // d08 arg      bare
    coping = lintel;                                    // d09 assign   bare
    if (tale == "") return lintel;                      // d10 return   bare
    return span;
  endfunction

  // ---- D2: a CAST OUTSIDE the condition window ----------------------
  function automatic int cast_elsewhere(int unsigned span);
    int    joist = 81;
    int    tally = 0;
    string note;
    tally = int'(joist);                                // d21 assignment RHS
    note  = $sformatf("%0d", int'(joist));              // d22 call ARGUMENT
    while (int'(joist) > 90) joist = joist - 1;         // d23 WHILE control
    for (int k = 0; k < int'(span); k = k + 1)          // d24 FOR control
      tally = tally + 1;
    repeat (int'(span)) tally = tally + 1;              // d25 REPEAT count
    do tally = tally + 1; while (int'(joist) > 90);     // d26 DO-WHILE control
    case (joist) inside
      [int'(span):100]: tally = tally + 1;              // d27 `case ... inside`
      default:          tally = tally + 2;
    endcase
    if (tally == 0) return int'(joist);                 // d28 RETURN
    return tally;
  endfunction

  // ---- D3a: the DEPTH half of S refVarLocalWindowBinds5 -------------
  // The corpus head's own neighbours: an `if` CONDITION one control body
  // deeper than the declaration is golden-BARE with or without a cast.
  function automatic int deeper(int unsigned span);
    int quoin = 91;
    int outcome = 0;
    if (span == 1) begin
      if (int'(quoin) == 91) outcome = 1;               // d31 CAST, one body deeper
      if (quoin == 91)       outcome = 2;               // d32 bare, one body deeper
      if (int'(span) == 1)   outcome = 3;               // d33 CAST formal, deeper
    end
    else begin
      if (int'(quoin) == 91) outcome = 4;               // d34 CAST, else body
      if (quoin == 91)       outcome = 5;               // d35 bare, else body
    end
    return outcome;
  endfunction

  // ---- D3b: S namedBlkLocalNoBind144v's condition-column twin --------
  // r10v161 scoped its fix to the assert/case-item window ON PURPOSE; this
  // pass keeps a SEPARATE counter so the named-block condition cells cannot
  // move with the cast cells.
  function automatic int named_blocks();
    int outcome = 0;
    begin : lodge
      static int sconce = 5;
      if (sconce == 5)        outcome = 1;              // d41 named-blk local, ifcond
      if (int'(sconce) == 5)  outcome = 2;              // d42 named-blk local + CAST
      assert (sconce == 5);                             // d43 named-blk local, assert
    end
    begin
      static int rafter = 6;
      if (rafter == 6)        outcome = outcome + 1;    // d44 UNNAMED blk local
      if (int'(rafter) == 6)  outcome = outcome + 2;    // d45 UNNAMED blk + CAST
    end
    return outcome;
  endfunction

  // ---- D3c: an EVENT CONTROL and a WAIT ------------------------------
  task automatic waits();
    int gable = 7;
    @(chime);                                           // d51 event control
    wait (gable == 7);                                  // d52 wait, bare
    wait (int'(gable) == 7);                            // d53 wait, CAST
    fork
      begin
        if (int'(gable) == 7) coping = 1;               // d54 fork arm, CAST
        if (gable == 7)       coping = 2;               // d55 fork arm, bare
      end
    join_none
  endtask
endclass

module harness164_d;
  Stay164 sy;
  int roll;
  initial begin
    sy = new();
    roll = sy.no_cast(5, 4'd9) + sy.cast_elsewhere(5)
         + sy.deeper(1) + sy.named_blocks();
    sy.waits();
  end
endmodule
