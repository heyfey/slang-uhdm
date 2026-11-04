// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; } s_t;
virtual class c;
  pure virtual function void f(s_t y);
  function void h(s_t z); endfunction
endclass
module dut (output int o);
  s_t r;
  initial begin r = 0; o = r.a; end
endmodule
