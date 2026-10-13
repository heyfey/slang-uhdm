// § clsLvTrailIdxNamesByChain310
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct { int idx[4]; } h_t;
interface ifc; h_t h; int i; int r; function void t(); h.idx[i + 1] = r; endfunction endinterface
module top; ifc u(); endmodule
