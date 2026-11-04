// § methRecvIdxAtPath312
package p; class item; int f; function int get(); return f; endfunction endclass
class grid; item iarr[4]; int i; int r; function void probe(); r = iarr[iarr[i].get()].f; endfunction endclass endpackage
module top; endmodule
