// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; int b; } s_t;
virtual class c #(parameter int N = 1);
  pure virtual function s_t f(s_t y);
endclass
module dut (output int o);
  function s_t g(s_t y); return y; endfunction
  s_t r;
  initial begin r = g(r); o = r.a; end
endmodule
