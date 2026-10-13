// § methRecvIdxAtPath312
class item; int f; function int get(); return f; endfunction endclass
interface ifc; item iarr[4]; int i; int r; int ia[4]; initial r = ia[iarr[i].get()] + iarr[iarr[i].get()].f; endinterface
module top; ifc u(); endmodule
