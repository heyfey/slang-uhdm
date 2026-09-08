// r10uvm209 grid arm B — THE LIFETIME KEYWORD, the distinguisher between
// "carry the source variable's lifetime" and "stamp every hoisted local
// automatic".  Three constructor body locals of one kind: one plain, one
// written `static`, one written `automatic`.  A rule that infers instead of
// carrying cannot tell the first two apart.
package pb209;
  class cb209b;
    int n;
  endclass
  class cd209;
    int q;
    extern function new();
  endclass
  function cd209::new();
    cb209b        lb_plain;
    static cb209b lb_static;
    automatic cb209b lb_auto;
    static int    lb_int_static;
    automatic int lb_int_auto;
    lb_plain = null;
    q = 2;
  endfunction
endpackage

import pb209::*;

module gb209;
  initial $display("b");
endmodule
