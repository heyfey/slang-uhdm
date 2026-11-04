// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; int b; } s_t;
virtual class base;
  pure virtual function void f(s_t y);
endclass
virtual class mid extends base;
  pure virtual function void g(s_t y);
endclass
module dut (output int o);
  s_t r;
  initial o = r.a;
endmodule
