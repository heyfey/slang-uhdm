// § builtinMethPathInIdxNameSpan314
class item; int f; endclass
class holder; int idx[4]; int q[$]; endclass
class grid; item iarr[4]; string s2[4][4]; int i; int j; int r; function void probe(); r = iarr[s2[i][j].len()].f; endfunction endclass
module top; endmodule
