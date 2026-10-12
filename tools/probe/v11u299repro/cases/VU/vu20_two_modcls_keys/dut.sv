// § unitTdClassFormalWriter299
typedef union packed { int a; bit [31:0] b; } u_t;
module zb;
  class c;
    function u_t f(u_t y); return y; endfunction
  endclass
endmodule
module aa;
  class c;
    function u_t f(u_t y); return y; endfunction
  endclass
  zb z();
endmodule
module top;
  aa a();
  function u_t g(u_t y); return y; endfunction
  u_t r;
  initial r = g(r);
endmodule
