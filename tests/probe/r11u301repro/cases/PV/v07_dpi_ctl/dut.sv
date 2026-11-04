// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; } s_t;
import "DPI-C" function void dpf(input s_t y);
virtual class c;
  pure virtual function void f(s_t y);
endclass
module dut (output int o);
  s_t r;
  initial begin r = 0; o = r.a; end
endmodule
