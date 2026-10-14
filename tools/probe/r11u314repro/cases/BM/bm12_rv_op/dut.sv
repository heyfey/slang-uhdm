// § builtinMethPathInIdxNameSpan314
class item; int f; endclass
class holder; int idx[4]; int q[$]; endclass
class grid; item iarr[4]; string sarr[4]; int i; int r; function void probe(); r = iarr[sarr[i].len() - 1].f; endfunction endclass
module top; endmodule
