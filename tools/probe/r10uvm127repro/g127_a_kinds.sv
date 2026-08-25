// r10uvm127 grid A — CALLEE KINDS reached from a package free function's
// DIRECT `return`.  MEASUREMENT ONLY.
//
// EVERY callee whose actuals are expected to take a stamp is UNFOLDABLE: it is
// a DPI-C import (no body at all) or its body reaches one.  `ExprEval::evalFunc`
// stamps the actuals BEFORE it discovers whether the body evaluates, and when
// the body DOES fold, the whole call is replaced by the constant and the
// stamped actuals leave the tree with it — a FOLDABLE callee therefore reads
// exactly like an unstamped one, and cannot test this law.  `emberFold` below
// is the deliberate fold fence.
package Larkspur;
  typedef enum bit [2:0] { QUILL_0, QUILL_7, QUILL_9 } quill_e;

  import "DPI-C"         function int    marlinProbe(int seedling);
  import "DPI-C" context function int    wickerJoin (string leftPart, byte hinge);
  import "DPI-C"         function int    tallowRender(quill_e mode, logic [17:0] bits18);
  import "DPI-C"         function void   burnishSink(string leftPart);

  // an SV-body callee that cannot fold (it reaches a DPI import)
  function automatic int slateThrough(string leftPart, byte hinge);
    return wickerJoin(leftPart, hinge);
  endfunction

  // an SV-body callee that DOES fold: golden's elaborated copy of any call to
  // it is a constant, so the call object never survives to carry a stamp
  function automatic int emberFold(int drift);
    return 7;
  endfunction

  // CALLERS ---------------------------------------------------------------
  function automatic int gantryTop(string leftPart, byte hinge);
    return wickerJoin(leftPart, hinge);                 // stamp (DPI context)
  endfunction

  function automatic int spindleTop(int seedling);
    return marlinProbe(seedling);                       // stamp (DPI plain)
  endfunction

  function automatic int vellumTop(quill_e mode, logic [17:0] bits18);
    return tallowRender(mode, bits18);                  // stamp (enum + vector)
  endfunction

  function automatic int trestleTop(string leftPart, byte hinge);
    return slateThrough(leftPart, hinge);               // stamp (SV, unfoldable)
  endfunction

  function automatic int cinderTop(int drift);
    return emberFold(drift);                            // FOLD FENCE
  endfunction

  // the FORWARD-REFERENCE fence (r10buvm8 pkgRetCalleeDeclaredFirst8v)
  function automatic int oxbowEarly(string leftPart, byte hinge);
    return laterJoin(leftPart, hinge);                  // bare (forward)
  endfunction

  import "DPI-C" function int laterJoin(string leftPart, byte hinge);

  // a NON-return statement calling the same callee: the window is closed
  function automatic int harrowNested(string leftPart, byte hinge);
    int keep;
    keep = wickerJoin(leftPart, hinge);                 // bare (assignment)
    return keep;
  endfunction

  // a task body has no `return` expression at all
  task automatic burnishTask(string leftPart);
    burnishSink(leftPart);                              // bare (task body)
  endtask
endpackage

module Larkspur_top;
  import Larkspur::*;
  int held;
  initial held = gantryTop("ab", 8'h2e);
endmodule
