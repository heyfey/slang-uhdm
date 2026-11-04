// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; } s_t;
virtual class b;
  pure virtual function void f(s_t y);
endclass
class d extends b;
  virtual function void f(s_t y); endfunction
endclass
module dut (output int o);
  s_t r;
  initial begin r = 0; o = r.a; end
endmodule
