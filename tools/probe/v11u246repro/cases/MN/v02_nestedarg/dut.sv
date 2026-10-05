// § macroParamMethNameEnd246
`define MNAME(X) dropped(X)
`define DO_CB(CB,METHOD) \
   begin \
     CB cb = new; \
     if (cb != null) begin \
       cb.METHOD; \
     end \
   end
package p;
  class cbc;
    function int dropped(int a); return a; endfunction
    function void raised(int a, int b); endfunction
  endclass
  class user;
    function void go(int x);
      `DO_CB(cbc, `MNAME(x))
      `DO_CB(cbc,   raised /* c */ (x, 2))
    endfunction
  endclass
endpackage
module top;
endmodule
