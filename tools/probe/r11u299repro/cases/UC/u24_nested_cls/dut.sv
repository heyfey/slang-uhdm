// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
class oc;
  class ic;
    function s_t f(s_t y); return y; endfunction
  endclass
  function s_t g(s_t y); return y; endfunction
endclass
module top;
  s_t r;
  initial r = '0;
endmodule
