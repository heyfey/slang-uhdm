// § macroParamMethNameEnd246
`define DO_CB(CB,METHOD) \
   begin \
     CB cb = new; \
     if (cb != null) begin \
       cb.METHOD; \
     end \
   end
package p;
  class cbc;
    function void raised(int a, int b); endfunction
    function int dropped(int a); return a; endfunction
  endclass
  class user;
    function void go(int x);
      `DO_CB(cbc, raised(x, 1))
    endfunction
  endclass
endpackage
module top;
endmodule
