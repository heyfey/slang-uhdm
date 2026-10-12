// § unitTdPureProtoFormalWriter301
typedef struct packed { int a; } s_t;
`define PV(n) pure virtual function void n(s_t y);
virtual class c;
  `PV(f)
endclass
module dut (output int o);
  s_t r;
  initial begin r = 0; o = r.a; end
endmodule
