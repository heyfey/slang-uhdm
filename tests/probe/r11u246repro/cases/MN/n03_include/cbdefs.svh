`define DO_CB(CB,METHOD) \
   begin \
     CB cb = new; \
     while (cb != null) begin \
       cb.METHOD; \
       cb = null; \
     end \
   end
