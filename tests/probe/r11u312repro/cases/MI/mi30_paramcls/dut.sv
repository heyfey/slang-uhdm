// § methRecvIdxAtPath312
class item; int f; function int get(); return f; endfunction endclass
class pc #(int N = 1); item iarr[4]; int i; int r; function void probe(); r = iarr[iarr[i].get() + N].f; endfunction endclass
module top; pc #(2) x; initial x = new; endmodule
