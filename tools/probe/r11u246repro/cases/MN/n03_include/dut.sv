// § macroParamMethNameEnd246
`include "cbdefs.svh"
package p;
  class cbc;
    function void raised(int a, int b); endfunction
  endclass
  class user;
    function void go(int x);
      `DO_CB(cbc, raised(x, 1))
    endfunction
  endclass
endpackage
module top;
endmodule
