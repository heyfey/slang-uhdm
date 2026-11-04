// § ppIdentEndInRebuiltText219 — a method-call actual forwarded through three multi-line macros before `cb.METHOD;`
`define DO_C(CB,OBJ,METHOD) \
   begin \
     CB cb = OBJ.first(); \
     if (cb != null) begin \
       cb.METHOD; \
     end \
   end
`define DO_B(CB,OBJ,METHOD) \
  `DO_C(CB,OBJ,METHOD)
`define DO_A(CB,METHOD) \
  `DO_B(CB,this,METHOD)
package p;
class cb_c;
  function void state_change(int a, int b); endfunction
endclass
class user_c;
  function cb_c first(); return null; endfunction
  function void run(int x);
    `DO_A(cb_c, state_change(x, 7))
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
