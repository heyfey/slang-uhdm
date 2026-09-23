package pk;
  typedef bit [2:0] b_t;
endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [5:0] a, output logic o);
  child #(.T(pk::b_t [1:0])) u (.a(a), .o(o));
endmodule
