// § unitTdClassFormalWriter299
typedef union packed { int a; bit [31:0] b; } u_t;
virtual class c;
  pure virtual function void f(u_t y);
endclass
module top;
  function u_t g(u_t y); return y; endfunction
  u_t r;
  initial r = g(r);
endmodule
