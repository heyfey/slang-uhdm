// § ppIdentEndInRebuiltText219 — the method-call macro argument is also stringified on the line before (`"... 'METHOD' ..."`), as uvm_do_obj_callbacks does
`define TRACE(M) $display(M);
`define DO_CB(T,OBJ,METHOD) \
   begin \
     `TRACE($sformatf(`"Executing callback method 'METHOD' for callback %s (T)`", "x")) \
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
    `DO_CB(user_c, cb, state_change(x, 5))
    `DO_CB(user_c, cb, ping())
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
