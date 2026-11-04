// § ppIdentEndInRebuiltText219 — the macros in an included header, used from a package class (uvm_callback_defines.svh's layout)
`include "defs.svh"
package p;
class cb_c;
  function void state_change(int a, int b); endfunction
  function string get_name(); return "n"; endfunction
endclass
class user_c;
  function cb_c first(); return null; endfunction
  function void run(int x);
    `DO_CB(user_c, cb_c, state_change(x, 5))
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
