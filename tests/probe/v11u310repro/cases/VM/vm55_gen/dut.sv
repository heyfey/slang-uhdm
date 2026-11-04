// § methTailIdxNestShape310
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
class item; int f; function int get(); return f; endfunction endclass
typedef struct { int k; } s_t;
module top; item iarr[4]; s_t s; int r;
  for (genvar g = 0; g < 2; g++) begin : gb initial r = iarr[s.k + g].get(); end
  if (1) begin : ib initial r = iarr[s.k].get(); end
endmodule
