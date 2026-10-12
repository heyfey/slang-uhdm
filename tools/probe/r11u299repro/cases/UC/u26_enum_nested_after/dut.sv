// § unitTdClassFormalWriter299
typedef enum logic [1:0] { A, B, C } e_t;
class oc;
  function bit g(e_t y); return y == A; endfunction
  class ic;
    function bit f(e_t y); return y == B; endfunction
  endclass
endclass
module top;
  function bit h(e_t y); return y == C; endfunction
  bit r;
  initial r = h(C);
endmodule
