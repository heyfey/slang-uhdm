// § methPathPlainElemZeroWidth314
class holder; int k; function int get(); return k; endfunction endclass
class item; int f; endclass
class grid; item iarr[4]; holder h; int r; function void probe(); r = iarr[h.get()].f; endfunction endclass
module top; endmodule
