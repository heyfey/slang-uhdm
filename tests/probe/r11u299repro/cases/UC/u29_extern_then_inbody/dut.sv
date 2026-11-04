// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
class c;
  extern function s_t f(s_t y);
  function s_t h(s_t y); return y; endfunction
endclass
function s_t c::f(s_t y); return y; endfunction
module top;
  s_t r;
  initial r = '0;
endmodule
