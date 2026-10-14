// § methPathPlainElemZeroWidth314
virtual class vitem; int f; pure virtual function int get(); endclass
class holder; vitem arr[4]; endclass
class item; int f; endclass
class grid; item iarr[4]; holder h; int i; int r; function void probe(); r = iarr[h.arr[i].get()].f; endfunction endclass
module top; endmodule
