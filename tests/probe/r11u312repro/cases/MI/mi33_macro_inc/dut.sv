// § methRecvIdxAtPath312
`include "defs.svh"
class item; int f; function int get(); return f; endfunction endclass
class grid; item iarr[4]; int i; int r; function void probe(); r = iarr[`RX].f; endfunction endclass
module top; endmodule
