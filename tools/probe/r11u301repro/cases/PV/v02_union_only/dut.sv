// § unitTdPureProtoFormalWriter301
typedef union packed { int a; bit [31:0] b; } u_t;
virtual class c;
  pure virtual function void f(u_t y);
endclass
module dut (output int o);
  u_t r;
  initial begin r = 0; o = r.a; end
endmodule
