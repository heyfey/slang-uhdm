// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
program prg;
  class c;
    function s_t f(s_t y); return y; endfunction
  endclass
endprogram
module top;
  function s_t g(s_t y); return y; endfunction
  s_t r;
  prg p();
  initial r = g(r);
endmodule
