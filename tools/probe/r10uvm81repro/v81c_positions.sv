// r10uvm81 VERIFIER arm C — LAW 1 POSITION grid, the statement kinds the
// implementer's c5/c6/c7 do NOT cover.  `condPredEarlyBound81` names exactly
// ConditionalStatement / CaseStatement predicates and lets ONLY blocks stand
// above them; every other position falls to the package variable.  These cells
// measure the ones nobody measured.
package pc93;
  int  sink;
  int  gate;
  int  arr [4];
  string sstr;

  class c93;
    string m_s;
    extern function new();
  endclass
  // the HOIST: a begin-block local `val` lifted into pc93's variable listing
  function c93::new();
    begin
      string val;
      val = "x";
      m_s = val;
    end
  endfunction

  // P1  repeat count                      P2  do..while condition
  function void p_repeat(int val);
    repeat (val) sink = sink + 1;                    // P1
  endfunction
  function void p_dowhile(int val);
    do sink = sink + 1; while (val != 0);            // P2
  endfunction

  // P3  foreach body ref                  P4  forever body ref
  function void p_foreach(int val);
    foreach (arr[k]) sink = arr[k] + val;            // P3
  endfunction

  // P5  ternary CONDITION                 P6  ternary arms
  function void p_ternary(int val);
    sink = (val != 0) ? 1 : 2;                       // P5 condition
    sink = (gate != 0) ? val : 3;                    // P6 true arm
  endfunction

  // P7  `case inside`  P8 `unique case`  P9 `priority case`  P10 casex/casez
  function void p_caseinside(int val);
    case (val) inside                                 // P7 case expr
      [0:3]: sink = 1;
      default: sink = 2;
    endcase
  endfunction
  function void p_uniquecase(int val);
    unique case (val)                                 // P8
      0: sink = 1;
      default: sink = 2;
    endcase
  endfunction
  function void p_prioritycase(int val);
    priority case (val)                               // P9
      0: sink = 1;
      default: sink = 2;
    endcase
  endfunction
  function void p_casez(int val);
    casez (val)                                       // P10
      0: sink = 1;
      default: sink = 2;
    endcase
  endfunction

  // P11 case ITEM expression (not the case expr)
  function void p_caseitem(int val);
    case (gate)
      val:     sink = 1;                              // P11
      default: sink = 2;
    endcase
  endfunction

  // P12 `unique if` predicate     P13 `priority if` predicate
  function void p_uniqueif(int val);
    unique if (val == 0) sink = 1;                    // P12
    else sink = 2;
  endfunction
  function void p_priorityif(int val);
    priority if (val == 0) sink = 1;                  // P13
    else sink = 2;
  endfunction

  // P14 ELSE-IF predicate (predicate under an ElseClause)
  function void p_elseif(int val);
    if (gate == 0) sink = 1;
    else if (val == 0) sink = 2;                      // P14
  endfunction

  // P15 an `if` predicate under a `while` body block
  function void p_whileif(int val);
    while (gate < 2) begin
      if (val == 0) sink = 3;                         // P15
      gate++;
    end
  endfunction

  // P16 an `if` predicate under a `repeat` body block
  function void p_repeatif(int val);
    repeat (2) begin
      if (val == 0) sink = 4;                         // P16
    end
  endfunction

  // P17 an `if` predicate under a `foreach` body block
  function void p_foreachif(int val);
    foreach (arr[k]) begin
      if (val == 0) sink = 5;                         // P17
    end
  endfunction

  // P18 an `if` predicate inside a NAMED block
  function void p_namedblk(int val);
    begin : nb93
      if (val == 0) sink = 6;                         // P18
    end
  endfunction

  // P19 immediate assertion condition     P20 $display argument
  function void p_assert(int val);
    assert (val != 0) sink = 1; else sink = 2;        // P19
  endfunction
  function void p_display(int val);
    $display("%0d", val);                             // P20
  endfunction

  // P21 index of an array select   P22 concatenation   P23 replication count
  function void p_index(int val);
    sink = arr[val];                                  // P21
    sink = {val, val};                                // P22
  endfunction

  // P24 a `return` under an if-branch
  function int p_retif(int val);
    if (gate == 0) return val;                        // P24
    return 0;
  endfunction

  // P25 method-call receiver arg / P26 a system function argument
  function void p_sysfn(int val);
    sink = $bits(val);                                // P26
  endfunction

  // P27 the CONTROL: a non-colliding formal in an if predicate + assignment
  function void p_free(int freearg);
    if (freearg == 0) sink = 1;
    sink = freearg;
  endfunction
endpackage
