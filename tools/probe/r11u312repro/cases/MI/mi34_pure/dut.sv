// § methRecvIdxAtPath312
virtual class vb; pure virtual function int get(); endclass
class grid; vb iarr[4]; int ia[4]; int i; int r; function void probe(); r = ia[iarr[i].get()] + iarr[iarr[i].get()].get(); endfunction endclass
module top; endmodule
