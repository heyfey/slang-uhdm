// § unitTdPureProtoFormalWriter301
typedef enum logic [1:0] { E0, E1 } e_t;
virtual class c;
  pure virtual function void f(e_t y);
endclass
module dut (output e_t o);
  function e_t g(e_t y); return y; endfunction
  initial o = g(E1);
endmodule
