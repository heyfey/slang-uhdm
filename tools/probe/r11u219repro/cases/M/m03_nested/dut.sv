// § ppIdentEndInRebuiltText219 § ppDotNameAfterArgToken219 — uvm_do_callbacks' shape: a method-call argument passed through two macros, after a multi-line trace macro that nests another multi-line macro
`define INFO(ID,MSG,VERB) \
   begin \
     if (VERB > 0) \
       $display("%s %s", ID, MSG); \
   end
`define TRACE_NOOBJ(CB,OPER) \
  begin \
    if(1) \
      `INFO("TRC", $sformatf("%s : callback %s (%s@%0d)" ,  \
       OPER, CB.get_name(), "x", 1), 1) \
  end
`define DO_OBJ_CB(T,CB,OBJ,METHOD) \
   begin \
     CB cb = OBJ.first(); \
     while(cb != null) begin \
       `TRACE_NOOBJ(cb,$sformatf(`"Executing callback method 'METHOD' for callback %s (CB) from %s (T)`",cb.get_name(), "x")) \
       cb.METHOD; \
       cb = null; \
     end \
   end
`define DO_CB(T,CB,METHOD) \
  `DO_OBJ_CB(T,CB,this,METHOD)

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
