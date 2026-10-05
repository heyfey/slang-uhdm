// § macroParamMethNameEnd246
`define GETN(O,N) O.get``N()
`define CALLM(O,M) \
   begin \
     O.M; \
   end
package p;
  class cbc;
    function int get1(); return 1; endfunction
    function int get22(); return 2; endfunction
    function void raised(int a); endfunction
  endclass
  class user;
    cbc cb;
    function void go(int x);
      int r;
      r = `GETN(cb, 1) + `GETN(cb, 22);
      `CALLM(cb, raised(x))
    endfunction
  endclass
endpackage
module top;
endmodule
