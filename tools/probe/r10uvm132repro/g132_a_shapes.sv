// r10uvm132 arm A — MACRO SHAPES.  One class-property receiver reached five
// ways: pasted-nested (the law's corpus shape), pasted with a different
// suffix, nested WITHOUT a paste, a single-level macro argument, macro BODY
// text, and plain source.  Only the PASTED shapes are cells; the rest are
// controls that must be byte-identical.
`include "g132_defs.svh"

module top_a132;
  string qbody132[$];

  class inner_a132;
    string qdot132[$];
  endclass

  class cls_a132;
    inner_a132 h_dot132;
    string qpaste132[$];
    string qsuffix132[$];
    string qnest132[$];
    string qone132[$];
    string qplain132[$];

    function void run_a132();
      `G132_QDA(QUEUE, qpaste132)
      // a MULTI-COMPONENT receiver written as ONE macro argument, so both
      // names live in ONE argument buffer and the law's chain rebuild has two
      // links to place (a two-buffer dotted receiver is
      // § macroSplitRecvIsAstChain128's cell, not this one — arm F measures
      // that one staying still).
      `G132_QDA(QUEUE, h_dot132.qdot132)
      `G132_QDA2(QUEUE, qsuffix132, "s")
      `G132_NEST(qnest132)
      `G132_ONE(qone132)
      begin
        int sz132 = 3;
        while (qplain132.size() < sz132) qplain132.push_back("");
        while (qplain132.size() > sz132) void'(qplain132.pop_front());
      end
    endfunction
  endclass

  cls_a132 h_a132;
  initial begin
    `G132_BODY(0)
  end
endmodule
