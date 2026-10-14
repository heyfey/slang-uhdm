// § methPathPlainElemZeroWidth314
`define HH h
class item; int f; function int get(); return f; endfunction endclass
class holder; item arr[4]; endclass
class grid; item iarr[4]; holder h; int i; int r; function void probe(); r = iarr[`HH.arr[i].get()].f; endfunction endclass
module top; endmodule
