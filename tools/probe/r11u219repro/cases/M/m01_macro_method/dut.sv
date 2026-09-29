// § ppIdentEndInRebuiltText219 — a method call whose name and arguments are one macro argument pasted after `obj.`
`define DO_CB(OBJ,METHOD) \
   begin \
     OBJ.METHOD; \
   end

package p;
class cb_c;
  function void state_change(int a, int b); endfunction
  function void ping(); endfunction
endclass
class user_c;
  cb_c cb;
  function void run(int x);
    `DO_CB(cb, state_change(x, 5))
    `DO_CB(cb, ping())
    cb.state_change(x, 6);
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
