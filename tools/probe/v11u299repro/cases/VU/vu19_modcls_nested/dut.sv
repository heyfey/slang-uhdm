// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
module top;
  class oc;
    class ic;
      function s_t f(s_t y); return y; endfunction
    endclass
  endclass
  function s_t g(s_t y); return y; endfunction
  s_t r;
  initial r = g(r);
endmodule
