// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; int b; } s_t;
virtual class z_c;
  pure virtual function void f(s_t y);
endclass
class a_c;
  function void h(s_t y); endfunction
endclass
module dut (output int o);
  s_t r;
  initial o = r.a;
endmodule
