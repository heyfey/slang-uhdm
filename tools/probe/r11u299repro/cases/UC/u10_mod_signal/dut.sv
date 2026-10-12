// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
class c;
  function s_t f(s_t y); return y; endfunction
endclass
module top;
  s_t sig;
  function s_t g(s_t y); return y; endfunction
  assign sig = g('0);
endmodule
