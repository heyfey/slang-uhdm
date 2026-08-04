package pkg;
  typedef struct packed { logic [1:0] slow_clk_val; } t;
  parameter t T_DEF = '{slow_clk_val: 2'b10};
  parameter int I_DEF = 7;
endpackage

module m1 #(parameter P = '0)();      endmodule   // untyped, unbased-unsized default
module m2 #(parameter Q = 3)();       endmodule   // untyped, plain decimal default
module m3 #(parameter R = 2'b01)();   endmodule   // untyped, based literal default
module m4 #(parameter int S = 3)();   endmodule   // TYPED default
module m5 #(parameter T = '0)();      endmodule

module dut();
  parameter pkg::t LOC = '{slow_clk_val: 2'b11};
  m1 #(.P(pkg::T_DEF)) a();     // override w/ pkg STRUCT param
  m2 #(.Q(pkg::I_DEF)) b();     // override w/ pkg INT param
  m4 #(.S(pkg::I_DEF)) c();     // typed formal, pkg INT param
  m5 #(.T(LOC))        d();     // override w/ LOCAL struct param
endmodule
