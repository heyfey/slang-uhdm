// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
class c;
  extern function s_t f(s_t y);
endclass
function s_t c::f(s_t y); return y; endfunction
module top;
  function s_t g(s_t y); return y; endfunction
  s_t r;
  initial r = g(r);
endmodule
