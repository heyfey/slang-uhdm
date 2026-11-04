// § methRecvIdxAtPath312
class item; int f; function int get(); return f; endfunction endclass
class grid; item iarr[4]; int i; int r; extern function void probe(); endclass
function void grid::probe(); r = iarr[iarr[i].get()].f; endfunction
module top; endmodule
