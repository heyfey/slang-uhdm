// § methRecvIdxAtPath312
class item; int f; function int get(); return f; endfunction endclass
class grid; item iarr[4]; int ia[4]; int r; function void probe(); foreach (ia[i]) r = iarr[iarr[i].get()].f; endfunction endclass
module top; endmodule
