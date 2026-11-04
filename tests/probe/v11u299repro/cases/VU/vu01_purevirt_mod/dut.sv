// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
virtual class c;
  pure virtual function s_t f(s_t y);
endclass
module top;
  function s_t g(s_t y); return y; endfunction
  s_t r;
  initial r = g(r);
endmodule
