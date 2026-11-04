// § builtinMethPathInIdxNameSpan314
class item; int f; endclass
class holder; int idx[4]; int q[$]; endclass
module top; item iarr[4]; string sarr[4]; int i; int r; always_comb r = iarr[sarr[i].len()].f; endmodule
