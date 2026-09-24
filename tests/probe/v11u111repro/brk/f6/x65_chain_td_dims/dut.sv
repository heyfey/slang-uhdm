package pk;
  typedef logic [1:0] w_t;
  typedef w_t w2_t;
endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [5:0] a, output logic o);
  child #(.T(pk::w2_t [2:0])) u (.a(a), .o(o));
endmodule
