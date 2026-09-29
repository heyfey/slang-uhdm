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

