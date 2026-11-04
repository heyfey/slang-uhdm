// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
class c;
  function s_t f(s_t y); return y; endfunction
endclass
module m2;
  function s_t g(s_t y); return y; endfunction
  s_t r;
  initial r = g(r);
endmodule
module top;
  function s_t g(s_t y); return y; endfunction
  s_t r;
  initial r = g(r);
  m2 u();
endmodule
