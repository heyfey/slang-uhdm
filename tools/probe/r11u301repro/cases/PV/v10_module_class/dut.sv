// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; } s_t;
module dut (output int o);
  virtual class c;
    pure virtual function void f(s_t y);
  endclass
  function s_t g(s_t y); return y; endfunction
  s_t r;
  initial begin r = g(r); o = r.a; end
endmodule
