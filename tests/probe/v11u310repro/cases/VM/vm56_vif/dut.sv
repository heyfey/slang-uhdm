// § methTailIdxNestShape310
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
interface ifc; int k; endinterface
class item; int f; function int get(); return f; endfunction endclass
class grid; virtual ifc vif; item iarr[4]; int r; function void probe(); r = iarr[vif.k].get(); endfunction endclass
module top; ifc u(); endmodule
