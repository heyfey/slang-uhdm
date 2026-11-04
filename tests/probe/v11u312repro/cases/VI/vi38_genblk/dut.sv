// § methRecvIdxAtPath312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
class item; int f; function int get(); return f; endfunction endclass
module top; item iarr[4]; int ia[4]; int r; int i;
  if (1) begin : g initial r = ia[iarr[i].get()]; end
endmodule
