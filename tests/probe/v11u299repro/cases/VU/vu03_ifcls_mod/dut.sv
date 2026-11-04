// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
interface ifc;
  class c;
    function s_t f(s_t y); return y; endfunction
  endclass
endinterface
module top;
  function s_t g(s_t y); return y; endfunction
  s_t r;
  ifc i();
  initial r = g(r);
endmodule
