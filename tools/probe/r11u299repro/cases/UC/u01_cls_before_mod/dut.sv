// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
class c;
  function s_t f(s_t y); return y; endfunction
endclass
module top;
  function s_t g(s_t y); return y; endfunction
  s_t r; c h;
  initial begin h = new(); r = g(r); end
endmodule
