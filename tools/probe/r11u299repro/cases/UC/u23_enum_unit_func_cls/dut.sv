// § unitTdClassFormalWriter299
typedef enum logic [1:0] { A, B, C } e_t;
function automatic bit uf(e_t y); return y == A; endfunction
class c;
  function bit f(e_t y); return y == B; endfunction
endclass
module top;
  bit r;
  initial r = uf(C);
endmodule
