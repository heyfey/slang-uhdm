// § macroParamMethNameEnd246
`define CALL(O) O.raised(1, 2)
package p;
  class cbc;
    function void raised(int a, int b); endfunction
  endclass
  class user;
    function void go();
      cbc cb = new;
      cb.raised(1, 2);
      `CALL(cb);
    endfunction
  endclass
endpackage
module top;
endmodule
