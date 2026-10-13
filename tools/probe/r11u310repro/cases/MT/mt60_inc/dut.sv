// § methRecvSelCallIdxDecompiled310
`include "defs.svh"
class item; int f; int k; function int get(); return f; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; endclass
class grid;
  item iarr[4]; holder h; int r;
  function void probe();
    r = `GETIT(iarr);
  endfunction
endclass
module top; endmodule
