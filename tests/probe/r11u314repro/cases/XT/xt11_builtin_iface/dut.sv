// § builtinMethPathInIdxNameSpan314
class item; int f; endclass
interface ifc; item iarr[4]; string sarr[4]; int i; int r; always_comb r = iarr[sarr[i].len()].f; endinterface
module top; ifc u(); endmodule
