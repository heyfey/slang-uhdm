// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
class aa;
  function s_t f(s_t y); return y; endfunction
endclass
module top;
  class mc;
    function s_t f(s_t y); return y; endfunction
  endclass
  s_t r;
  initial r = '0;
endmodule
