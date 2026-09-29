// § ppIdentEndInRebuiltText219 — the method-call actual is itself a macro call (`METH), forwarded through a second macro
`define METH state_change(x, 5)
`define DO_C(CB,METHOD) \
   begin \
     CB cb = null; \
     if (cb != null) \
       cb.METHOD; \
   end
`define DO_B(CB,METHOD) \
  `DO_C(CB,METHOD)
package p;
class cb_c;
  function void state_change(int a, int b); endfunction
endclass
class user_c;
  function void run(int x);
    `DO_B(cb_c, `METH)
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
