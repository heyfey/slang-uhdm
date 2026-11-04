// § classRetFillUnsized433
class C;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  function s_t f(); return '1; endfunction
  function bit g(); return '1; endfunction
endclass
module top; C c; initial c = new; endmodule
