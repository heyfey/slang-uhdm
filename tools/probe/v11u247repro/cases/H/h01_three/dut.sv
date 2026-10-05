// § cloneStmtHomeVarDupKeyByOrder247
`define DO \
   begin \
     it iter = new(); \
     it cb = iter.first(); \
     while (cb != null) cb = iter.next(); \
   end
package p;
  class it;
    function it first(); return this; endfunction
    function it next(); return null; endfunction
  endclass
  class fac;
    extern task emit();
  endclass
  task fac::emit();
    `DO
    `DO
    `DO
  endtask
endpackage
module top;
  import p::*;
  fac z;
endmodule
