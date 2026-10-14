// § methPathPlainElemZeroWidth314
class item; int f; extern function int get(); endclass
class holder; item arr[4]; endclass
class grid; item iarr[4]; holder h; int i; int r; function void probe(); r = iarr[h.arr[i].get()].f; endfunction endclass
function int item::get(); return f; endfunction
module top; endmodule
