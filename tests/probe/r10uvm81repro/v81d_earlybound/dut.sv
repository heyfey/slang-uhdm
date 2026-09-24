// r10uvm81 VERIFIER arm D — the FULL early-bound family.  Surelog compiles an
// expression against the ENCLOSING statement (`pstmt`) at exactly four kinds of
// site, and only those:
//   CompileStmt.cpp:1322  compileConditionalStmt   the `if` PREDICATE
//   CompileStmt.cpp:1445  compileCaseStmt          the CASE CONDITION
//   CompileStmt.cpp:1505  compileCaseStmt          the CASE **ITEM** EXPRESSION
//   CompileAssertion.cpp:284/289/294  compileSimpleImmediateAssertion
//                                     the ASSERTION EXPRESSION *and* BOTH
//                                     ACTION-BLOCK statements
// The implementer's `condPredEarlyBound81` encodes only the first two.  This arm
// measures the other two families and their interaction with the "only BLOCKS
// may stand above" rule.
package pd94;
  int  sink;
  int  gate;

  class c94;
    string m_s;
    extern function new();
  endclass
  function c94::new();
    begin
      string val;
      val = "x";
      m_s = val;
    end
  endfunction

  // ---- CASE ITEM expressions, every case flavour -------------------------
  function void d_caseitem(int val);
    case (gate)
      val:     sink = 1;                    // D1 plain case ITEM
      default: sink = 2;
    endcase
  endfunction
  function void d_casezitem(int val);
    casez (gate)
      val:     sink = 1;                    // D2 casez ITEM
      default: sink = 2;
    endcase
  endfunction
  function void d_casexitem(int val);
    casex (gate)
      val:     sink = 1;                    // D3 casex ITEM
      default: sink = 2;
    endcase
  endfunction
  function void d_insideitem(int val);
    case (gate) inside
      [0:val]: sink = 1;                    // D4 case-inside RANGE item
      default: sink = 2;
    endcase
  endfunction
  function void d_multiitem(int val);
    case (gate)
      val, 3:  sink = 1;                    // D5 one of several item exprs
      default: sink = 2;
    endcase
  endfunction
  function void d_itemstmt(int val);
    case (gate)
      0:       sink = val;                  // D6 case item STATEMENT (not expr)
      default: sink = 2;
    endcase
  endfunction

  // ---- IMMEDIATE ASSERTION expression and ACTION BLOCK --------------------
  function void d_assert(int val);
    assert (val != 0) sink = 1; else sink = 2;        // D7 assert EXPRESSION
  endfunction
  function void d_assertthen(int val);
    assert (gate != 0) sink = val; else sink = 2;     // D8 assert THEN action
  endfunction
  function void d_assertelse(int val);
    assert (gate != 0) sink = 1; else sink = val;     // D9 assert ELSE action
  endfunction
  function void d_assertbare(int val);
    assert (val != 0);                                // D10 no action block
  endfunction
  function void d_assertblk(int val);
    assert (gate != 0) begin sink = val; end          // D11 action block BEGIN
    else begin sink = 2; end
  endfunction
  function void d_assertifin(int val);
    assert (gate != 0) begin
      if (val == 0) sink = 3;                         // D12 `if` pred in action
    end
  endfunction

  // ---- the same, one plain `begin` deep and one IF-BRANCH deep ------------
  function void d_itemdeepblk(int val);
    begin
      case (gate)
        val:     sink = 1;                  // D13 case ITEM, one plain begin
        default: sink = 2;
      endcase
    end
  endfunction
  function void d_itemdeepif(int val);
    if (gate == 0) begin
      case (gate)
        val:     sink = 1;                  // D14 case ITEM under an IF branch
        default: sink = 2;
      endcase
    end
  endfunction
  function void d_assertdeepblk(int val);
    begin
      assert (val != 0) sink = 1;           // D15 assert expr, one plain begin
    end
  endfunction
  function void d_assertdeepif(int val);
    if (gate == 0) begin
      assert (val != 0) sink = 1;           // D16 assert expr under IF branch
    end
  endfunction

  // ---- other statement kinds that pass their OWN object, for contrast -----
  function void d_disable(int val);
    sink = val;                             // D17 plain assignment (pkg var)
  endfunction

  // ---- CONTROL: a non-colliding formal in every one of the above ----------
  function void d_free(int freearg);
    case (gate)
      freearg: sink = 1;
      default: sink = 2;
    endcase
    assert (freearg != 0) sink = freearg; else sink = freearg;
  endfunction
endpackage

// A MODULE twin of the whole arm: nothing here may ever move.
module md94;
  int sink, gate;
  logic val;
  function void m_caseitem(int val);
    case (gate)
      val:     sink = 1;
      default: sink = 2;
    endcase
  endfunction
  function void m_assert(int val);
    assert (val != 0) sink = 1; else sink = 2;
  endfunction
  initial begin m_caseitem(1); m_assert(1); end
endmodule
