// § builtinMethPathInIdxNameSpan314
class item; int f; endclass
class holder; int idx[4]; int q[$]; endclass
class grid; item iarr[4]; holder hs[4]; int i; int r; function void probe(); r = iarr[hs[i].q.size()].f; endfunction endclass
module top; endmodule
