// r10uvm81 VERIFIER arm G — the residual CASE shapes the fix's new
// StandardCaseItem/`matchesOrInside` clause decides, measured rather than argued:
// a PLAIN (non-range) item under `case … inside`, a `case … matches` pattern
// item, a `randcase` weight, a `case` item expression that is an OPERATION, a
// default item, and a case whose expression is a call argument.
package pg97;
  int sink, gate;
  typedef union tagged { int A; int B; } tu97;
  class c97;
    string m_s;
    extern function new();
  endclass
  function c97::new();
    begin
      string val;
      val = "x";
      m_s = val;
    end
  endfunction

  // G1 plain (NON-range) item under `case … inside`
  function void g_insideplain(int val);
    case (gate) inside
      val:     sink = 1;
      default: sink = 2;
    endcase
  endfunction

  // G2 a range item under `case … inside` whose bound is the formal (control)
  function void g_insiderange(int val);
    case (gate) inside
      [0:val]: sink = 1;
      default: sink = 2;
    endcase
  endfunction

  // G3 a case ITEM expression that is an OPERATION over the formal
  function void g_itemop(int val);
    case (gate)
      val + 1: sink = 1;
      default: sink = 2;
    endcase
  endfunction

  // G4 randcase weight
  function void g_randcase(int val);
    randcase
      val: sink = 1;
      1:   sink = 2;
    endcase
  endfunction

  // G5 the case EXPRESSION is an operation over the formal
  function void g_condop(int val);
    case (val + 1)
      0:       sink = 1;
      default: sink = 2;
    endcase
  endfunction

  // G6 a nested case: the INNER case's item expression, inside the OUTER's
  //    item statement (the outer item's clause is late-bound)
  function void g_nestitem(int val);
    case (gate)
      0: case (gate)
           val:     sink = 1;
           default: sink = 2;
         endcase
      default: sink = 3;
    endcase
  endfunction

  // G7 an `if` predicate inside a case ITEM's statement
  function void g_caseitemif(int val);
    case (gate)
      0:       if (val == 0) sink = 1;
      default: sink = 2;
    endcase
  endfunction

  // G8 the CONTROL: a non-colliding formal everywhere
  function void g_free(int freearg);
    case (gate) inside
      freearg: sink = 1;
      default: sink = 2;
    endcase
    case (gate)
      freearg + 1: sink = 3;
      default:     sink = 4;
    endcase
  endfunction
endpackage
