// § unitTdClassFormalWriter299
typedef enum logic [1:0] { A, B, C } e_t;
task automatic ut(input e_t y, output bit z); z = (y == A); endtask
module top;
  class c;
    function bit f(e_t y); return y == B; endfunction
  endclass
  function bit g(e_t y); return y == C; endfunction
  bit r;
  initial r = g(A);
endmodule
