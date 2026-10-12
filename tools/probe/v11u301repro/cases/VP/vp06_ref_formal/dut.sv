// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; int b; } s_t;
virtual class c;
  pure virtual function void f(ref s_t y);
endclass
module dut (output int o);
  s_t r;
  initial o = r.a;
endmodule
