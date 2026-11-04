// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
class c #(int W = 1);
  function s_t f(s_t y); return y; endfunction
endclass
module top;
  function s_t g(s_t y); return y; endfunction
  s_t r; c #(4) h;
  initial begin h = new(); r = g(h.f(r)); end
endmodule
