// § lvRootSelCallNameSpan312
typedef struct packed { logic [3:0] b; } s_t;
module top; for (genvar g = 0; g < 1; g++) begin : gb s_t m [4]; int i; always_comb m[fn(i)].b = 0; end function automatic int fn(int x); return x; endfunction endmodule
