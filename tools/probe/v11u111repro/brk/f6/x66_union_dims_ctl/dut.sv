package pk;
  typedef union packed { logic [1:0] a; logic [1:0] b; } u_t;
endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [3:0] a, output logic o);
  child #(.T(pk::u_t [1:0])) u (.a(a), .o(o));
endmodule
