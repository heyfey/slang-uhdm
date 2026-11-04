// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
class Zc;
  function s_t f(s_t y); return y; endfunction
endclass
module m;
  class a;
    function s_t h(s_t y); return y; endfunction
  endclass
  s_t r;
  initial r = '0;
endmodule
module top;
  m u();
endmodule
