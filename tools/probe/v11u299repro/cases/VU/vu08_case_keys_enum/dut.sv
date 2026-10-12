// § unitTdClassFormalWriter299
typedef enum logic [1:0] { A, B, C } e_t;
class Zc;
  function bit f(e_t y); return y == A; endfunction
endclass
module m;
  class a;
    function bit h(e_t y); return y == B; endfunction
  endclass
  bit r;
  initial r = 1'b0;
endmodule
module top;
  m u();
  function bit g(e_t y); return y == C; endfunction
endmodule
