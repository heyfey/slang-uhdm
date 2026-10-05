// § cloneStmtHomeVarDupKeyByOrder247
`define DOCB \
   begin \
     it iter = new(); \
     it cb = iter.first(); \
     while (cb != null) begin \
       cb = iter.next(); \
     end \
   end
