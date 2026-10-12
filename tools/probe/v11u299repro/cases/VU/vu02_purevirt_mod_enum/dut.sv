// § unitTdClassFormalWriter299
typedef enum logic [1:0] { A, B, C } e_t;
virtual class c;
  pure virtual function bit f(e_t y);
endclass
class d;
  function bit h(e_t y); return y == A; endfunction
endclass
module top;
  function bit g(e_t y); return y == B; endfunction
  bit r;
  initial r = g(C);
endmodule
