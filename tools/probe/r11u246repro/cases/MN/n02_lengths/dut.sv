// § macroParamMethNameEnd246
`define DO_CB(CB,METHOD) \
   begin \
     CB cb = new; \
     if (cb != null) begin \
       cb.METHOD; \
     end \
   end
`define DO_CB1(CB,METHOD) begin CB cb = new; cb.METHOD; end
package p;
  class cbc;
    function void raised(int a, int b); endfunction
    function void dropped(int a); endfunction
    function void x(); endfunction
    function void a_long_method_name(int a); endfunction
  endclass
  class user;
    function void go(int x);
      `DO_CB(cbc, raised(x, 1))
      `DO_CB(cbc, dropped(x))
      `DO_CB(cbc, x())
      `DO_CB(cbc, a_long_method_name(x + 1))
      `DO_CB1(cbc, dropped(x))
    endfunction
  endclass
endpackage
module top;
endmodule
