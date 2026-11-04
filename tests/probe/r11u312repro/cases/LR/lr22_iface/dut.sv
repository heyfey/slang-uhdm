// § lvRootSelCallNameSpan312
typedef struct packed { logic [3:0] b; } s_t;
interface ifc; s_t m [4]; int i; function automatic int fn(int x); return x; endfunction always_comb m[fn(i)].b = 0; endinterface
module top; ifc u(); endmodule
