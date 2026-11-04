// § lvRootSelCallNameSpan312
class item; int f; endclass
class grid; item iarr[4]; int i; int r; function void probe(); iarr[fwd(i)].f = r; endfunction function int fwd(int y); return y; endfunction endclass
module top; endmodule
