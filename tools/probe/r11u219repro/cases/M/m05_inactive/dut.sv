// § ppIdentEndInRebuiltText219 — an inactive `ifdef branch and a stringified formal before a method call that is one macro argument
`define DO(OBJ, METHOD) \
  begin \
`ifdef NEVER_DEFINED \
    $display("never"); \
    $display("never again"); \
`endif \
    $display(`"METHOD on OBJ`"); \
    OBJ.METHOD; \
  end
`define WRAP(OBJ, METHOD) \
  `DO(OBJ, METHOD)
package p;
class c;
  function void notify(int a, int s); endfunction
  function void run(int x);
    `WRAP(this, notify(x, 7))
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
