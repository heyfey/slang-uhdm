// § methPathPlainElemZeroWidth314
class holder; int k; holder hh; function int get(); return k; endfunction endclass
class item; int f; endclass
class grid; item iarr[4]; holder h; int r; function void probe(); r = iarr[h.hh.get()].f; endfunction endclass
module top; endmodule
