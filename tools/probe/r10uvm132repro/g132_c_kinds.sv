// r10uvm132 arm C — RECEIVER KINDS under the PASTED macro: a class PROPERTY, a
// method LOCAL, a method FORMAL, a MODULE-level variable and a PACKAGE
// variable.  Every one is a single written name, so every one is a cell.
`include "g132_defs.svh"

package pkg_c132;
  string qpkgvar132[$];
endpackage

module top_c132;
  import pkg_c132::*;
  string qmod132[$];

  class cls_c132;
    string qprop132[$];

    function void run_c132(ref string qformal132[$]);
      string qlocal132[$];
      `G132_QDA(QUEUE, qprop132)
      `G132_QDA(QUEUE, qlocal132)
      `G132_QDA(QUEUE, qformal132)
    endfunction
  endclass

  cls_c132 h_c132;
  initial begin
    `G132_QDA(QUEUE, qmod132)
    `G132_QDA(QUEUE, qpkgvar132)
  end
endmodule
