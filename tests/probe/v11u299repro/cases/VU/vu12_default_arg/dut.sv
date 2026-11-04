// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
class c;
  function s_t f(int k, s_t y = '0); return y; endfunction
endclass
module top;
  function s_t g(s_t y); return y; endfunction
  s_t r;
  initial r = g(r);
endmodule
