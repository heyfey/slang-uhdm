// § methPathPlainElemZeroWidth314
class item; int f; function int get(); return f; endfunction endclass
class holder; item arr[4]; endclass
module top; item iarr[4]; holder h; int i; int r; always_comb r = iarr[h.arr[i].get()].f; endmodule
