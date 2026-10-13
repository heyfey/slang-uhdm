// § methRecvIdxAtPath312
class item; int f; function int get(); return f; endfunction endclass
module top; item iarr[4]; int i; int r; int ia[4]; initial r = ia[iarr[i].get()]; endmodule
