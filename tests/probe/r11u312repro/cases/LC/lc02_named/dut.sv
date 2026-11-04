// § lateCallIdxNameSpan312
class item; int f; item nx; function int get(); return f; endfunction endclass
class holder; int k; int idx[4]; endclass
class grid; item iarr[4]; int ia[4]; holder h; int i; int j; bit c; int r; function void probe(); r = iarr[fwd(.y(h.k))].get(); endfunction function int fwd(int y); return y; endfunction endclass
module top; endmodule
