// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; int b; } s_t;
interface class ic;
  pure virtual function void f(s_t y);
endclass
class k implements ic;
  virtual function void f(s_t y); endfunction
endclass
module dut (output int o);
  s_t r;
  initial o = r.a;
endmodule
