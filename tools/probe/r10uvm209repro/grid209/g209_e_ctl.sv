// r10uvm209 grid arm E — THE NEGATIVE CONTROL.  The same shape as arm A minus
// the one thing the law names: this package has NO out-of-body constructor, so
// its listing carries no hoisted local and the patched binary must reproduce
// the pristine one CELL FOR CELL.  It must be ABSENT from the wide boundary's
// moved-arm list; if it moves, the law is reaching something it does not name.
package pe209;
  class ci209;
    int n;
    function new();
      ci209 ie_cls;
      ie_cls = null;
      n = 0;
    endfunction
  endclass
  ci209  pe_cls;
  ci209  pe_cls_new = new();
  int    pe_int = 9;
  string pe_str = "pe";
  int    pe_assoc[string];
endpackage

import pe209::*;

module ge209;
  initial $display("%0d", pe_int);
endmodule
