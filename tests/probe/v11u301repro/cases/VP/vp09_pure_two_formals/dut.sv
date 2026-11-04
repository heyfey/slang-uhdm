// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; int b; } s_t;
virtual class c;
  pure virtual function void f(s_t y,
                               s_t z);
endclass
module dut (output int o);
  s_t r;
  initial o = r.a;
endmodule
