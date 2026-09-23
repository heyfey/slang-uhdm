package pk;
  typedef logic [2:0] w_t;
  typedef enum logic [1:0] { E0, E1 } e_t;
endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [5:0] a, output logic o, output logic p, output logic q);
  child #(.T(pk::w_t [1:0])) u (.a(a), .o(o));
  child #(.T(pk::e_t [2:0])) v (.a(a), .o(p));
  child #(.T(pk::w_t)) w (.a(a[2:0]), .o(q));
endmodule
