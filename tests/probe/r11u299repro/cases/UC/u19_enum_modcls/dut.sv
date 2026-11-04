// § unitTdClassFormalWriter299
typedef enum logic [1:0] { A, B, C } e_t;
module top;
  class mc;
    function bit f(e_t y); return y == A; endfunction
  endclass
  function bit g(e_t y); return y == B; endfunction
  bit r;
  initial r = g(C);
endmodule
