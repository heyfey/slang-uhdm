// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; } s_t;
virtual class c;
  pure virtual function void f(int k, s_t y, input s_t z);
endclass
module dut (output int o);
  s_t r;
  initial begin r = 0; o = r.a; end
endmodule
