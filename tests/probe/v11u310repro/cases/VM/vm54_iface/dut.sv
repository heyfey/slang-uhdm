// § methTailIdxNestShape310
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
class item; int f; function int get(); return f; endfunction endclass
class holder; int k; endclass
interface ifc; item iarr[4]; holder h; int r; initial r = iarr[h.k].get(); endinterface
module top; ifc u(); endmodule
