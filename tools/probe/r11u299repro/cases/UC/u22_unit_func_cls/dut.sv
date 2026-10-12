// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
function automatic s_t uf(s_t y); return y; endfunction
class c;
  function s_t f(s_t y); return y; endfunction
endclass
module top;
  s_t r;
  initial r = uf(r);
endmodule
