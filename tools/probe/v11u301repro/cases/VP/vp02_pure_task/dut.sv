// § unitTdPureProtoFormalWriter301
typedef union packed { int a; logic [31:0] b; } u_t;
virtual class c;
  pure virtual task t(input u_t y);
endclass
module dut (output int o);
  function u_t g(u_t y); return y; endfunction
  u_t r;
  initial begin r = g(r); o = r.a; end
endmodule
