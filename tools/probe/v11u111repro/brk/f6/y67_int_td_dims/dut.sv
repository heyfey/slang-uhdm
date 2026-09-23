package pk;
  typedef int i_t;
endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [63:0] a, output logic o);
  child #(.T(pk::i_t [1:0])) u (.a(a), .o(o));
endmodule
