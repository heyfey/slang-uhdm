// § unitUnpackedUnionTd249
typedef union { int a; shortint b; } u_t;
module top;
  function automatic int f(u_t x); return x.a; endfunction
  u_t v; int r;
  initial r = f(v);
endmodule
