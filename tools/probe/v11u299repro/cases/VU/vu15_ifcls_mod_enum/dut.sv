// § unitTdClassFormalWriter299
typedef enum logic [1:0] { A, B, C } e_t;
interface ifc;
  class c;
    function bit f(e_t y); return y == A; endfunction
  endclass
endinterface
module top;
  function bit g(e_t y); return y == B; endfunction
  bit r;
  ifc i();
  initial r = g(C);
endmodule
