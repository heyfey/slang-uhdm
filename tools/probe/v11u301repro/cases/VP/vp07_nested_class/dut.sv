// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; int b; } s_t;
class outer;
  virtual class inner;
    pure virtual function void f(s_t y);
  endclass
endclass
module dut (output int o);
  s_t r;
  initial o = r.a;
endmodule
