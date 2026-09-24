package pk;
  typedef logic bit1_t;
endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [3:0] a, output logic o);
  child #(.T(pk::bit1_t [3:0])) u (.a(a), .o(o));
endmodule
