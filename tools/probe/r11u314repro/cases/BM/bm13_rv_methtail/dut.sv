// § builtinMethPathInIdxNameSpan314
class item; int f; function int get(); return f; endfunction endclass
class grid; item iarr[4]; string sarr[4]; int i; int r; function void probe(); r = iarr[sarr[i].len()].get(); endfunction endclass
module top; endmodule
