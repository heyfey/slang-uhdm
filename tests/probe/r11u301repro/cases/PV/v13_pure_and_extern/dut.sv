// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; } s_t;
virtual class c;
  pure virtual function void f(s_t y);
  extern function void e(s_t z);
endclass
function void c::e(s_t z); endfunction
module dut (output int o);
  s_t r;
  initial begin r = 0; o = r.a; end
endmodule
