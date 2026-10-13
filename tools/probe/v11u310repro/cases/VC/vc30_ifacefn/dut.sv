// § castTsLvIdxByChain310
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct { int f; int g[4]; } e_t;
interface ifc; e_t sa[4]; int i; function void t(); sa[int'(i)].f = 1; sa[1].g[int'(i)]++; endfunction endinterface
module top; ifc u(); endmodule
