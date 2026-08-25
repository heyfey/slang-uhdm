// r10uvm132 arm F — THE NEGATIVE CONTROLS THAT SURELOG COMPILES.  Every
// receiver here is written inside a PASTED macro invocation, so only the law's
// OTHER fences can keep it still: the FIT (a SCOPED name does not start where
// its bound component does), the `this`/`super` head, and the chain's own
// refusal for a SELECT.  The DOTTED receiver through a class handle is the one
// MULTI-COMPONENT shape the chain accepts, and it is here to show the law
// firing on it too.
`include "g132_defs.svh"

package pkg_f132;
  string qpkg132[$];
endpackage

module top_f132;
  string qarr132[2][$];

  class inner_f132;
    string qi132[$];
  endclass

  class cls_f132;
    string qthis132[$];
    inner_f132 h132;

    function void run_f132();
      `G132_QDA(SCOPED, qpkg132)
      `G132_QDA(THIS, qthis132)
      `G132_QDA(DOT, h132)
    endfunction
  endclass

  cls_f132 h_f132;
  initial begin
    `G132_QDA(IDX, qarr132)
  end
endmodule
