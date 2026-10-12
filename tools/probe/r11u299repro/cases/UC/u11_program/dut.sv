// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
class c;
  function s_t f(s_t y); return y; endfunction
endclass
program prg;
  function s_t g(s_t y); return y; endfunction
  s_t r;
  initial r = g(r);
endprogram
module top;
  prg p();
endmodule
